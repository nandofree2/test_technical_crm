

# Tenant Isolation and Server-Side Authorization

## Summary

The application uses the user's first active membership as the current tenant:

```ruby
current_user.memberships.active.first
```
`model/membership.rb`
validate :only_active_membership_per_user, if: :active?
this validate handle only one membership can active even user have many membership so it can block user for access other tenant (user can switch membership for active on profile)

Authorization is implemented with CanCanCan in `app/models/ability.rb`. Controllers additionally scope database queries through `current_organization`.

The company and opportunity flows enforce tenant isolation correctly. The main remaining authorization gaps are in `app/controllers/users_controller.rb`:

- Any authenticated user can list every user as JSON.
- Any authenticated user can edit or update another user by changing the URL ID.
- Any authenticated user can create another user.
- Opportunity assignment parameters are restricted to administrators by the controller.

## How Tenant Selection Works

### `app/controllers/application_controller.rb`

`before_action :authenticate_user!` comes from Devise and requires authentication for every controller inheriting from `ApplicationController`.

`current_organization` returns the organization belonging to the current user's first active membership:

```ruby
current_user.memberships.active.first&.organization
```

`current_user_membership` returns that active membership and is used for role checks such as `admin?` and `sales?`.

`sales_members` returns active sales memberships from `current_organization`. It is used by assignment forms.

`rescue_from CanCan::AccessDenied` handles failed authorization. HTML requests redirect to `root_path`; JSON requests receive HTTP `403` and an error object.

The tenant model assumes that only one membership is active at a time. Switching organizations changes the old membership to inactive and the selected membership to active. so user cannt see/use action the other organization 

## Authorization Rules

### `app/models/ability.rb`

`Ability#initialize(user)` obtains the user's first active membership. If there is no active membership, the user receives no permissions.

For administrators:

```ruby
can :read, Organization, id: organization_id
can :manage, Company, organization_id: organization_id
can :manage, Opportunity, organization_id: organization_id
```

An administrator can manage companies and opportunities only in the active organization.

For sales users:

```ruby
can %i[read update], Company,
  organization_id: organization_id,
  users: { id: user.id }

can %i[read update], Opportunity,
  organization_id: organization_id,
  users: { id: user.id }
```

A salesperson can read and update only records that are both:

1. In the active organization.
2. Assigned to that salesperson.

Sales users cannot create, destroy, or manage arbitrary records.

## Controllers

### `app/controllers/companies_controller.rb`

`authorize_resource` applies CanCanCan authorization to company actions.

`index` builds the query from `current_organization.companies` and then applies `accessible_by(current_ability)`. This combines tenant isolation with role and assignment rules before search, ordering, and pagination.

`new` and `create` build companies through `current_organization.companies.new`. The organization is therefore chosen by the server, not by a submitted `organization_id`.

`set_company` loads a company through:

```ruby
current_organization.companies.find(params[:id])
```

A company from another organization cannot be loaded by ID and is redirected to `companies_path`.

`company_params` permits `user_ids` only when the current active membership is an administrator. This is a server-side restriction; hiding the field in the view is not the security mechanism.

### `app/controllers/opportunities_controller.rb`

`index` scopes opportunities through:

```ruby
current_organization.opportunities.accessible_by(current_ability)
```

The same filtered relation is used for search results, pagination, stage summaries, counts, and estimated-value totals. Foreign records therefore do not appear in any of those results.

`set_opportunity` loads records through the current organization, preventing direct-ID access to another tenant's opportunity.

`set_search_company` displays only companies in the current organization that the current user can access.

`new` and `create` build opportunities through the current organization, so a forged `organization_id` is not trusted.

`opportunity_params` restricts assignment changes to administrators:

```ruby
permitted = [:title, :estimated_value, :stage, :company_id]
```

`user_ids` is added only when `current_user_membership&.admin?` is true. A forged `user_ids` submitted by a salesperson is discarded by strong parameters, while permitted fields such as the title can still be updated when the salesperson is assigned to the opportunity.

This is server-side enforcement and does not depend on the assignment field being hidden in the view.

### `app/controllers/organizations_controller.rb`

`authorize_resource` authorizes the organization loaded by the controller.

`index` uses `Organization.accessible_by(current_ability)`, so users see only their active organization.

`set_organization` initially uses `Organization.find(params[:id])`, but CanCanCan authorization subsequently rejects an organization outside the active tenant.

`show` loads memberships and companies for the authorized organization. Administrators see all companies. Sales users see only companies assigned to themselves.

The memberships display includes inactive memberships belonging to that authorized organization. It does not expose memberships from unrelated organizations through this action.

### `app/controllers/dashboard_controller.rb`

`index` contains no tenant-specific logic. Authentication still applies through `ApplicationController`, but the action currently has no protected data query.

## Membership Switching Service

### `app/services/membership_operation/switch_service.rb`

`SwitchService#initialize(user, membership_id)` stores the current user and requested membership ID.

`SwitchService#switch` loads the target with:

```ruby
@user.memberships.find_by(id: @membership_id)
```

This ensures the user can switch only to an organization where they have a membership.

Inside a transaction it:

1. Finds the current active membership.
2. Marks it inactive if it is different from the target.
3. Marks the target membership active.

Failures are logged and converted to a `false` result with an error message.

The model validation prevents multiple active memberships

## Models

### `app/models/membership.rb`

Defines the user-to-organization relationship, `admin` and `sales` roles, and `active` and `inactive` statuses.

`only_active_membership_per_user` rejects a new active membership when the user already has another active membership.

### `app/models/organization.rb`

Owns memberships, users, companies, and opportunities.

### `app/models/company.rb`

`assigned_sales_users_must_belong_to_organization` checks every assigned user and requires an active membership in the company's organization.

This blocks cross-organization assignments.

### `app/models/opportunity.rb`

`company_must_belong_to_organization` requires the opportunity's company to have the same organization ID as the opportunity.

`assigned_sales_users_must_belong_to_organization` requires every assigned user to be an active member of the opportunity's organization.

These validations block cross-tenant references but do not decide whether the current salesperson is allowed to change assignments. That authorization must be enforced by the controller or Ability rules.

### `app/models/user.rb`

Provides Devise authentication and relationships to memberships, organizations, companies, and opportunities.validation for name, email, and password.

### `app/models/assign_sales_company.rb`

Join model connecting users and companies. Tenant correctness is delegated to `Company` and controller authorization.

### `app/models/assign_sales_opportunity.rb`

Join model connecting users and opportunities. Tenant correctness is delegated to `Opportunity` and controller authorization.

## Views

### `app/views/companies/index.html.erb`

Displays the organization collection filtered by `current_organization.companies.accessible_by(current_ability)`. Uses `can?(:create, ...)` to hide the new-company control and `can?(:update, company)` to hide edit links. Direct requests are still protected by the controller.

### `app/views/companies/_form.html.erb`

Displays assignment checkboxes only for administrators and receives active sales members from the current organization. This is correct presentation logic, but forged requests are handled by `company_params` and the company validation.

### `app/views/companies/show.html.erb`

Displays a company already loaded and authorized by the controller. The `can?(:update, @company)` check only controls whether the edit link is visible.

### `app/views/opportunities/index.html.erb`

Displays the already-filtered opportunity collection and summary by `current_organization.opportunity.accessible_by(current_ability)`. Uses `can?(:create, ...)` to hide the new-opportunity control and `can?(:update, company)` to hide edit links. Direct requests are still protected by the controller 

### `app/views/opportunities/_form.html.erb`

Hides assignment controls from sales users. The controller also rejects forged `user_ids`, so this is a usability restriction backed by server-side enforcement.

### `app/views/opportunities/show.html.erb`

Displays an opportunity already loaded and authorized by the controller. The update permission check controls the edit link only.

### `app/views/organizations/index.html.erb`

Displays the organization collection filtered by `Organization.accessible_by(current_ability)`.

### `app/views/organizations/show.html.erb`

Displays members and companies supplied by the controller.

### `app/views/users/show.html.erb`

Displays the current user's profile and memberships. It submits membership IDs to the switching service, which performs the ownership check.

### `app/views/layouts/_navbar.html.erb`

Displays navigation links and user actions. Navigation visibility does not authorize requests; users can still manually call routes.

## Routes

### `config/routes.rb`

`resources :companies` and `resources :opportunities` expose CRUD endpoints protected by their controllers.

`resources :organizations` exposes organization routes protected by `authorize_resource`.

`resources :users` exposes user endpoints. 

The `switch_organization` member route is safe from membership ownership bypass because the service scopes the requested membership to `current_user`.

## Database Constraints

### `db/schema.rb`

The database provides foreign keys between organizations, companies, opportunities, users, memberships, and assignment tables.

It also provides unique indexes for:

- One membership per user and organization.
- One company name per organization.
- One assignment row per user and company.
- One assignment row per user and opportunity.

The schema does not enforce:

- Only one active membership per user.
- Assignment users and assigned records belonging to the same organization.
- Opportunity company and opportunity organization matching.
- Whether the current user is authorized to update a record.

Those protections currently depend on model validation, controller scoping, and CanCanCan.

## Existing Security Tests

Relevant tests are located in:

- `spec/requests/tenant_isolation_spec.rb`
- `spec/requests/companies_spec.rb`
- `spec/requests/opportunity_authorization_spec.rb`
- `spec/requests/organizations_spec.rb`
- `spec/services/membership_operation/switch_service_spec.rb`
- `spec/models/ability_spec.rb`
- `spec/requests/authentication_spec.rb`

The tests cover foreign organization access, administrator isolation, sales assignment restrictions, forged organization IDs, cross-organization companies, organization switching, and unauthenticated access.

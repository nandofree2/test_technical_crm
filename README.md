# Multi-Tenant CRM Test
# disclaimer 
## - i remove delete/destroy method controller beacause in realcase we are restricted to delete data, use VOID its more clean for track record but idont implement it
## - i use gem cancancan and devise because i have experience in the real project my current personal project https://eco-frontend-pi.vercel.app/ RBAC and tenant Isolation as refference 
# supported Document
## `Manual test.pdf`
## `Structure code explanation.md`
# CI/CD progress on branch
  `feature-1-create-devise-template`
  `feature-2-create-main-model`
  `feature-3-create-user-view-service`
  `feature-4-create-company-and-ability`
  `feature-5-create-ability-logic`
  `feature-6-create-opportunity-and-ability`
  `feature-7-fix-opportunity`
  `feature-8-create-test-automation`
  `feature-9-final-test-and-add-supported-document`
  `main`

## Setup

Requirements: Ruby from `.ruby-version`, PostgreSQL, and Bundler.
Rails 7.2.3.2
ruby 3.1.2p20
```bash
bundle install
cp .env.example .env
bin/rails db:create
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```
if u wan to rollback
```bash
bin/rails db:rollback STEP=8
```

all seeds on db/seeds.rb

Set the PostgreSQL values in `.env.example` before running Rails:

```dotenv
DB_USERNAME=your_postgres_user
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
RAILS_MAX_THREADS=5
```

Open `http://localhost:3000`.

## Sample Accounts, Membership, Company

All seeded users use password `12341234`.

- Admin: `admin_a@test.com`
- Admin with multiple memberships: `admin_and_sales_b@test.com`
- Sales: `sales_a@test.com`
- Sales: `sales_b@test.com`
Users created: Admin A - admin_a@test.com - 12341234
Users created: Admin and Sales B - admin_and_sales_b@test.com - 12341234
Users created: Admin C - admin_c@test.com - 12341234
Users created: Admin D - admin_d@test.com - 12341234
Users created: Sales A - sales_a@test.com - 12341234
Users created: Sales B - sales_b@test.com - 12341234
Users created: Sales C - sales_c@test.com - 12341234
Users created: Sales D - sales_d@test.com - 12341234
----------------------------------------------------
Users created: 8
----------------------------------------------------
Organization created: PT Akalin Aja - pt-akalin-aja
----------------------------------------------------
Membership created: Admin A - admin - active
Membership created: Admin and Sales B - admin - active
Membership created: Sales A - sales - active
Membership created: Sales B - sales - active
----------------------------------------------------
Organization created: CV Bandung Membara - cv-bandung-membara
----------------------------------------------------
Membership created: Admin A - admin - inactive
Membership created: Admin and Sales B - sales - inactive
Membership created: Sales C - sales - inactive
Membership created: Sales D - sales - active
----------------------------------------------------
Organization created: PT Cipta Mandiri - pt-cipta-mandiri
----------------------------------------------------
Membership created: Admin C - admin - active
Membership created: Sales C - sales - active
Memberships created: 10


## RSpec Tests
Note: Try to manual test on interface first for best experience

Install/update dependencies and run the complete suite:

```bash
bundle install
bin/rails db:test:prepare
bundle exec rspec
```

Run one file or one example:

```bash
bundle exec rspec spec/models/opportunity_spec.rb
bundle exec rspec spec/requests/tenant_isolation_spec.rb:4
```

The suite currently contains 30 examples covering membership rules, organization switching, authentication, tenant isolation, role authorization, Company and Opportunity CRUD, cross-organization assignments, negative values, company search, stage filtering, and summary calculations.

Each example prints a structured test log:

```text
[TEST] WHAT: Tenant isolation prevents sales from accessing another sales user's opportunity
[TEST] PROCESS: ./spec/requests/tenant_isolation_spec.rb:49
[TEST] RESULT: PASS
```

## Tenant Isolation

The active organization is derived server-side from the current user's active membership. Company and opportunity queries are scoped from `current_organization`; record lookup does not trust an organization ID from the browser. Opportunity validation requires its company to belong to the same organization, and assigned users must be active members of that organization.

CanCanCan enforces authorization server-side. Sales users can read and update only assigned records, while admins can manage records in the active organization (company and opportunity).

## Assumptions and Libraries

A user has one active membership at a time and can belong to multiple organizations. Membership screens are out of scope and memberships are created by seeds. Estimated values use PostgreSQL integer storage. The application uses Rails, PostgreSQL, Devise, CanCanCan, Ransack, Kaminari, Importmap, Turbo Rails, Stimulus Rails, and RSpec Rails.

AI coding assistance was used to inspect bug/error lib installment, syntax. i also use for auto correct, Rspec/ automated test template.  

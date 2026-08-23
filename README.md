# Multi-Tenant CRM Test
Disclaimer i use my current personal project https://eco-frontend-pi.vercel.app/ RBAC and tenant Isolation as refference 

## Setup

Requirements: Ruby from `.ruby-version`, PostgreSQL, and Bundler.
Rails 7.2.3.2
ruby 3.1.2p20
```bash
bundle install
cp .env.example .env
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Set the PostgreSQL values in `.env.example` before running Rails:

```dotenv
DB_USERNAME=your_postgres_user
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
RAILS_MAX_THREADS=5
```

Open `http://localhost:3000`.

## Sample Accounts

All seeded users use password `12341234`.

- Admin: `admin_a@test.com`
- Admin with multiple memberships: `admin_and_sales_b@test.com`
- Sales: `sales_a@test.com`
- Sales: `sales_b@test.com`

## RSpec Tests

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

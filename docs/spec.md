# BillWatch Specification

Personal bill tracking app with a year-at-a-glance calendar view and multi-user account support.

## Overview

| Attribute | Value |
|-----------|-------|
| **Problem Statement** | Users need a simple way to track recurring bills and see their payment schedule at a glance |
| **Target Users** | Individuals and small families managing household bills |
| **Scope** | MVP with core calendar and multi-user features |
| **Expected Scale** | Personal/small team use (1-50 users, <1,000 bills total) |

## Stack

| Component | Technology |
|-----------|------------|
| Framework | Phoenix 1.8.3 / LiveView |
| Database | SQLite + Ecto |
| Auth | `mix phx.gen.auth` with scopes (email/password, `--no-magic-link`) |
| Recurrence | Cocktail (iCalendar RRULE) |
| Styling | TailwindCSS (custom design) |

## Feature Specs

- [Authentication & Accounts](./authentication.md)
- [Calendar](./calendar.md)

## Data Model Overview

```
Account
├── AccountUser (role: admin | member)
│   └── User
├── Category
└── Bill
```

| Entity | Belongs To | Notes |
|--------|------------|-------|
| User | — | Auth credentials |
| Account | — | Tenant container |
| AccountUser | Account, User | Join table with role; unique constraint on user_id |
| Category | Account | Bill categorization |
| Bill | Account, Category | Recurring or one-time; all fields editable |

## Multi-tenancy

All data scoped to account. Current scope (user, account, role) loaded on auth. Enforced via:

- Plug for controller requests
- `on_mount` hook for LiveViews
- Context functions require `account_id`

## Roles & Permissions

| Role | Bills | Categories | Members | Account |
|------|:-----:|:----------:|:-------:|:-------:|
| Admin | CRUD | CRUD | Manage | Delete |
| Member | CRUD | View | — | — |

## Core Flows

### New User Registration

1. Enter email, password, invite code
2. Validate invite code (single global code via environment variable)
3. Create user → account → account_user (admin)
4. Seed default categories
5. Send verification email
6. User verifies email → access app

### Invited User Registration

1. Receive invite email with token
2. Click link, enter password
3. Create user → account_user (with invited role)
4. Send verification email
5. User verifies email → access app

### User Self-Removal

1. User can leave their account voluntarily
2. Admins blocked from leaving if they're the last admin
3. Leaving deletes the user record entirely

### Calendar Usage

1. View year calendar with bills displayed on due dates
2. Filter by category via hamburger menu
3. Click day → see bill details in modal
4. Add/edit/delete bills (all fields editable)
5. Navigate between years

## Configuration

| Setting | Dev | Prod |
|---------|-----|------|
| Database | SQLite (local file) | SQLite (local file) |
| Email | Swoosh Local (`/dev/mailbox`) | Postmark or Sendgrid via SMTP |
| Invite Code | `"tryme"` | Environment variable (`INVITE_CODE`) |

## Non-Functional Requirements

| Aspect | Requirement |
|--------|-------------|
| Logging | Phoenix default (errors to stdout) |
| Monitoring | None for MVP |
| Accessibility | TBD / not prioritized for MVP |
| Data Limits | None enforced (SQLite handles expected scale) |

## Open Questions

- [ ] Accessibility standards for future iterations
- [ ] Mobile app strategy (if needed beyond responsive web)

## Future Considerations

Not in MVP, but possible extensions:

- **Payment tracking** — Mark bills as paid, track history
- **Reminders** — Email/push notifications before due dates
- **Recurring variations** — Bi-weekly, quarterly, custom intervals
- **Budget view** — Monthly/yearly spending breakdown
- **Import/export** — CSV, iCalendar integration
- **Mobile app** — React Native or native wrapper

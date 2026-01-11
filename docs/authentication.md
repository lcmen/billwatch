# Authentication & Accounts Specification

## Overview

Email/password authentication using Phoenix 1.8's `phx.gen.auth` with scopes. Account-based multi-tenancy where users belong to exactly one account. Role-based permissions control access to account management features.

**Note:** Phoenix 1.8 defaults to magic links. Generate with `--no-magic-link` flag for traditional email/password auth.

---

## Models

### User

Standard Phoenix auth generator fields.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid | PK |
| email | string | unique, required, case-insensitive |
| hashed_password | string | required |
| confirmed_at | utc_datetime | email verification timestamp |
| timestamps | | inserted_at, updated_at |

### Account

| Field | Type | Notes |
|-------|------|-------|
| id | uuid | PK |
| name | string | required |
| timestamps | | |

### AccountUser

Join table enforcing single-account membership.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid | PK |
| account_id | uuid | FK → accounts, required |
| user_id | uuid | FK → users, required, **unique** |
| role | enum | `:admin` or `:member` |
| timestamps | | |

**Constraints:**
- Unique index on `user_id` ensures one account per user
- Cascade delete from both account and user

### Invitation

| Field | Type | Notes |
|-------|------|-------|
| id | uuid | PK |
| account_id | uuid | FK → accounts, required |
| email | string | required |
| role | enum | `:admin` or `:member` |
| token | string | unique, required |
| expires_at | utc_datetime | required (e.g., 7 days from creation) |
| accepted_at | utc_datetime | nullable; set when invitation is used |
| invited_by_id | uuid | FK → users, **nilify on delete** |
| timestamps | | |

**Behavior:**
- Invitations remain valid if the inviter is demoted or removed (invited_by_id becomes nil)
- Pending invitations persist until explicitly revoked or accepted
- Same email can be re-invited after revocation (no cooldown)

---

## Roles & Permissions

| Action | Admin | Member |
|--------|:-----:|:------:|
| View bills | ✓ | ✓ |
| Create/edit/delete bills | ✓ | ✓ |
| View categories | ✓ | ✓ |
| Manage categories | ✓ | ✗ |
| Invite users | ✓ | ✗ |
| Remove members | ✓ | ✗ |
| Promote/demote users | ✓ | ✗ |
| Update account settings | ✓ | ✗ |
| Delete account | ✓ | ✗ |
| Leave account (self-remove) | ✓* | ✓ |

*Admins can leave unless they are the last admin.

---

## Flows

### New Account Sign-up

1. User visits `/register`
2. Form requires:
   - Email
   - Password
   - Invite code
3. On submit:
   - Validate invite code (single global code from `INVITE_CODE` env var; `"tryme"` in dev)
   - Create `User`
   - Create `Account` (name defaults to user's email prefix or "My Account")
   - Create `AccountUser` with role: `:admin`
   - Seed default categories for account
   - Send verification email
4. User must verify email before accessing app

### Invited User Sign-up

1. Admin invites user from settings (email + role)
2. System creates `Invitation` with token and 7-day expiry, sends email
3. Invitee clicks link: `/register?token=xxx`
4. System validates token:
   - **Token invalid/not found** → Error page: "This invitation link is invalid."
   - **Token expired** → Error page: "This invitation has expired. Please contact your account administrator for a new invite."
   - **Token already used** → Error page: "This invitation has already been used." (with link to login)
   - **Token valid** → Show registration form
5. Form displays:
   - Email (pre-filled, readonly)
   - Password input
   - No invite code field
6. On submit:
   - Create `User` with `confirmed_at = now` (no email verification needed)
   - Create `AccountUser` with invited role
   - Mark invitation as accepted (`accepted_at = now`)
7. User is logged in and redirected to app immediately

**Note:** Email verification is skipped for invited users because the invitation email itself proves email ownership.

### Login

1. Email + password
2. Reject if email not verified
3. On success, load current scope (user + account + role) into session

### Password Reset

1. Request reset via email
2. Token-based link to reset form
3. Standard Phoenix auth flow

### Email Verification

1. Token sent on registration
2. Click link to confirm
3. Required before app access
4. **Verification links never expire** (MVP simplification)
5. User can request a new verification email anytime

### User Self-Removal (Leave Account)

1. User initiates from settings or profile
2. System checks if user is last admin
   - If last admin: block with error message
   - Otherwise: proceed
3. Delete user record entirely (cascades account_user)
4. Redirect to logged-out state

---

## Invitation Management

### List Invitations (Admin only)

```elixir
def list_invitations(account_id)
# Returns all unaccepted invitations (both pending and expired)
# Each invitation includes computed status:
#   - :pending (expires_at > now)
#   - :expired (expires_at <= now)
# Ordered by inserted_at desc (newest first)
```

### Create Invitation (Admin only)

```elixir
def create_invitation(account_id, attrs, invited_by)
# attrs: %{email: string, role: :admin | :member}
# Generates secure token
# Sets expires_at to 7 days from now
# Sends invitation email
# Returns {:ok, invitation} or {:error, changeset}
```

**Edge cases:**
- Email already has pending invitation → Return error
- Email belongs to existing user in account → Return error
- Email belongs to user in different account → Return error (users can only belong to one account)

### Accept Invitation

```elixir
def accept_invitation(token, user_params)
# Validates token:
#   - not found → {:error, :invalid_token}
#   - expired → {:error, :expired_token}
#   - already accepted → {:error, :already_accepted}
# Creates user with confirmed_at = now (no verification needed)
# Creates account_user with invitation's role
# Marks invitation accepted_at = now
# Returns {:ok, user} or {:error, reason}
```

### Resend Invitation (Admin only)

```elixir
def resend_invitation(invitation_id, account_id)
# Validates invitation is pending (not accepted)
# Generates new token
# Resets expires_at to 7 days from now
# Sends new invitation email
```

### Revoke Invitation (Admin only)

```elixir
def revoke_invitation(invitation_id, account_id)
# Deletes pending invitation
# No email sent on revocation
```

**Re-inviting:** After revocation, the same email can be immediately re-invited.

---

## Member Management (Admin only)

```elixir
def list_members(account_id)
# Returns [AccountUser with user preloaded]
# Ordered by inserted_at or email

def change_role(account_user_id, new_role, account_id)
# Validates account_user belongs to account
# Cannot demote last admin → {:error, :last_admin}
# Returns {:ok, account_user} or {:error, reason}

def remove_member(account_user_id, account_id)
# Validates account_user belongs to account
# Cannot remove self → {:error, :cannot_remove_self}
# Deletes user record entirely (cascades account_user)
# Returns :ok or {:error, reason}

def leave_account(user_id, account_id)
# For self-removal
# Cannot leave if last admin → {:error, :last_admin}
# Deletes user record entirely
# Returns :ok or {:error, reason}
```

---

## Account Management (Admin only)

```elixir
def update_account(account_id, attrs)
# attrs: %{name: string}
# Returns {:ok, account} or {:error, changeset}

def delete_account(account_id)
# Cascades: account_users, users, bills, categories, invitations
# Returns :ok
```

---

## Current Scope

After login, session holds user, account, and role. All queries scoped to `account_id`. Role checked for admin-only actions.

Scope loaded via:
- Plug for controller requests
- `on_mount` hook for LiveViews

```elixir
# Example scope struct
%{
  user: %User{id: "...", email: "..."},
  account: %Account{id: "...", name: "..."},
  role: :admin | :member
}
```

---

## Context Functions Summary

### Registration

| Function | Description |
|----------|-------------|
| `register_user_with_account(attrs, invite_code)` | Creates user + account + account_user (admin) + seeds categories |
| `register_invited_user(token, password_attrs)` | Creates user (pre-confirmed) + account_user with invited role |

### Authentication

| Function | Description |
|----------|-------------|
| `get_user_by_email_and_password(email, password)` | Returns user if credentials valid |
| `get_user_scope(user)` | Returns {account, role} for session |

### Invitations (Admin only)

| Function | Description |
|----------|-------------|
| `create_invitation(account_id, email, role, invited_by)` | Generates token, sends email |
| `list_invitations(account_id)` | All unaccepted invitations (pending and expired) |
| `resend_invitation(invitation_id, account_id)` | New token, reset expiry, resend email |
| `revoke_invitation(invitation_id, account_id)` | Deletes invitation |
| `get_invitation_by_token(token)` | Validates token exists and not expired |

### Members (Admin only)

| Function | Description |
|----------|-------------|
| `list_members(account_id)` | All account_users with user preloaded |
| `change_member_role(account_user_id, new_role, account_id)` | Cannot demote last admin |
| `remove_member(account_user_id, account_id)` | Cannot remove self, deletes user |
| `leave_account(user_id, account_id)` | Self-removal, cannot if last admin |

### Account (Admin only)

| Function | Description |
|----------|-------------|
| `update_account(account_id, attrs)` | Update account name |
| `delete_account(account_id)` | Cascades all related data |

---

## Routes

### Public (Unauthenticated)

| Path | Purpose |
|------|---------|
| `/register` | New account registration |
| `/register?token=xxx` | Invited user registration |
| `/login` | Login form |
| `/logout` | Logout action |
| `/reset-password` | Request password reset |
| `/reset-password/:token` | Reset password form |
| `/confirm/:token` | Email confirmation |
| `/confirm` | Resend confirmation email |

### Authenticated (Any Role)

| Path | Purpose |
|------|---------|
| `/` | Calendar (main app) |
| `/profile` | User profile, leave account option |

### Admin Only

| Path | Purpose |
|------|---------|
| `/settings` | Account settings (name) |
| `/settings/members` | Member management, invitations |
| `/settings/categories` | Category management |

---

## Database Schema

SQLite-compatible (use `:string` with `collate: :nocase` instead of `:citext`).

### accounts

```elixir
create table(:accounts, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :name, :string, null: false

  timestamps()
end
```

### users

```elixir
create table(:users, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :email, :string, null: false, collate: :nocase
  add :hashed_password, :string, null: false
  add :confirmed_at, :utc_datetime

  timestamps()
end

create unique_index(:users, [:email])
```

### account_users

```elixir
create table(:account_users, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
  add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
  add :role, :string, null: false  # "admin" or "member"

  timestamps()
end

create unique_index(:account_users, [:user_id])  # Enforces single account per user
create index(:account_users, [:account_id])
```

### invitations

```elixir
create table(:invitations, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
  add :invited_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
  add :email, :string, null: false
  add :role, :string, null: false  # "admin" or "member"
  add :token, :string, null: false
  add :expires_at, :utc_datetime, null: false
  add :accepted_at, :utc_datetime

  timestamps()
end

create unique_index(:invitations, [:token])
create index(:invitations, [:account_id])
create index(:invitations, [:email])
```

---

## Default Categories

Seeded on new account creation:

| Name | Color | Hex |
|------|-------|-----|
| Housing | Red | `#ef4444` |
| Utilities | Amber | `#f59e0b` |
| Insurance | Purple | `#8b5cf6` |
| Subscriptions | Emerald | `#10b981` |
| Finance | Blue | `#3b82f6` |
| Other | Gray | `#6b7280` |

---

## UI Pages

### Registration (`/register`)

**New account flow:**
- Email input
- Password input (with confirmation or strength indicator)
- Invite code input
- Submit button
- Link to login

**Invited flow** (`/register?token=xxx`):
- Email (readonly, pre-filled from invitation)
- Password input
- No invite code field
- Submit button

**After submit (new account):** Redirect to "verify your email" page.

**After submit (invited):** Logged in and redirected to app immediately.

**Invalid/expired token:** Error page with appropriate message (see Flows section).

### Login (`/login`)

- Email input
- Password input
- "Forgot password?" link
- "Sign up" link
- Submit button

### Settings — Account Tab (Admin only)

- Account name input
- Save button

### Settings — Members Tab (Admin only)

**Member list (active users):**
- Table showing: email, role badge, status ("Active"), actions
- Actions per member:
  - Change role dropdown (admin ↔ member)
  - Remove button (with confirmation)
- Current user row shows "You" indicator, no remove button

**Pending invitations:**
- Table showing: email, role, status, sent date, actions
- Status values:
  - **Pending** — Token valid, not yet accepted (shows expiry date)
  - **Expired** — Token past expiry date, not accepted
- Actions by status:
  | Status | Available Actions |
  |--------|-------------------|
  | Pending | Resend, Revoke |
  | Expired | Resend, Revoke |
- "Invited by" column omitted (or shows "—" if `invited_by_id` is nil)

**Resend behavior:**
- Generates new token
- Resets expiry to 7 days from now
- Sends new invitation email
- UI shows success toast: "Invitation resent to {email}"

**Invite form:**
- Email input
- Role select (Admin / Member)
- Send invitation button

### Settings — Categories Tab (Admin only)

- List: color swatch, name, edit button, delete button
- Add form: name input, color picker
- **Delete flow:** Confirmation modal asking which category to reassign existing bills to

### Profile Page (All users)

- Email (readonly)
- Change password section
- "Leave account" button (with confirmation)
  - Blocked with message if last admin

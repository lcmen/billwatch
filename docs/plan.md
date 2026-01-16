# BillWatch Auth Implementation Plan

## Overview
Implement user sign-up/login with multi-tenant support (Account/AccountUser) for BillWatch. Uses Phoenix 1.8's `phx.gen.auth` as foundation, customized for invite code validation and automatic account creation.

---

## Phase 1: Generate Base Authentication

- [x] **Step 1.1**: Run `mix phx.gen.auth Accounts User users --binary-id --no-live`
- [x] **Step 1.2**: Modify generated user migration for SQLite (already had `collate: :nocase`)
- [x] **Step 1.3**: Remove magic link functionality

---

## Phase 2: Create Account & AccountUser Schemas

- [x] **Step 2.1**: Create Account schema (`lib/billwatch/accounts/account.ex`) and migration
- [x] **Step 2.2**: Create AccountUser schema (`lib/billwatch/accounts/account_user.ex`) and migration
- [x] **Step 2.3**: Create Category schema (`lib/billwatch/bills/category.ex`) and migration
- [x] **Additional**: Reorganized fixtures by schema (users, accounts, account_users, categories)
- [x] **Additional**: Created comprehensive tests for all new schemas (29 new tests)

---

## Phase 3: Extend Scope for Multi-Tenancy

- [x] **Step 3.1**: Modify `lib/billwatch/accounts/scope.ex` to include account and role

---

## Phase 4: Implement Invite Code Validation

- [ ] **Step 4.1**: Add invite code configuration to `config/config.exs` and `config/runtime.exs`
- [ ] **Step 4.2**: Add invite_code virtual field and validation to User schema
- [ ] **Step 4.3**: Use invite_code when registering user

---

## Phase 5: Customize Registration Flow

- [x] **Step 5.1**: Modify `lib/billwatch/accounts.ex` with `register_user/1` transaction (already done in Phase 2)
- [x] **Step 5.2**: Add `get_user_account_and_role/1` to Accounts context

---

## Phase 6: Modify Auth Plugs

- [x] **Step 6.1**: Update `fetch_current_scope_for_user/2` to load account/role
- [ ] **Step 6.2**: Update `require_authenticated_user/2` plug to make sure user is confirmed

---

## Phase 7: Implement Landing Page with Modals

- [ ] **Step 7.1**: Create auth modal component (`lib/billwatch_web/components/auth_components.ex`)
- [ ] **Step 7.2**: Remove daisy UI
- [ ] **Step 7.3**: Replace homepage based on docs/design/home with modals for sign-up, sign-in, and password reset
- [ ] **Step 7.4**: Connect modals with query param so we can trigger particular modal when redirecting to homepage with
    right query param

---

## Phase 8: Create Placeholder Calendar Page

- [ ] **Step 8.1**: Create CalendarLive (`lib/billwatch_web/live/calendar_live.ex`)

---

## Phase 9: Update Layouts

- [ ] **Step 9.1**: Modify layouts for auth-aware navigation

---

## Phase 10: Run Migrations & Verify

- [ ] **Step 10.1**: Run `mix ecto.migrate`
- [ ] **Step 10.2**: Verify registration flow works
- [ ] **Step 10.3**: Verify login flow works
- [ ] **Step 10.4**: Verify email confirmation works

---

## Migration Order

1. `20260111182656_create_users_auth_tables.exs` (from phx.gen.auth) ✓ created
2. `20260112171143_create_accounts.exs` ✓ created
3. `20260112171307_create_account_users.exs` ✓ created (unique user_id, no default role)
4. `20260112171608_create_categories.exs` ✓ created

## Files Summary

| File | Status |
|------|--------|
| `lib/billwatch/accounts/user.ex` | ✓ Modified (has_one :account_user, has_one :account through association) |
| `lib/billwatch/accounts/user_token.ex` | ✓ Modified (removed magic link, added confirmation, accepts optional token param for testing) |
| `lib/billwatch/accounts/user_notifier.ex` | ✓ Modified (removed magic link emails) |
| `lib/billwatch/accounts.ex` | ✓ Modified (preloads account_user with account in get_user_by_session_token) |
| `lib/billwatch_web/user_auth.ex` | ✓ Refactored (chainable scope, renamed functions, public methods grouped, simplified logic) |
| `lib/billwatch_web/router.ex` | ✓ Modified (removed magic link route, added confirmation) |
| `lib/billwatch_web/controllers/user_session_controller.ex` | ✓ Modified (password-only login) |
| `lib/billwatch_web/controllers/user_registration_controller.ex` | ✓ Modified (uses confirmation email) |
| `lib/billwatch_web/controllers/user_confirmation_controller.ex` | ✓ Created |
| `lib/billwatch_web/controllers/user_session_html/new.html.heex` | ✓ Modified (password-only form) |
| `lib/billwatch_web/controllers/user_registration_html/new.html.heex` | ✓ Modified (added password field) |
| `lib/billwatch_web/controllers/user_session_html/confirm.html.heex` | ✓ Deleted |
| `lib/billwatch/accounts/account.ex` | ✓ Created (with changeset validation) |
| `lib/billwatch/accounts/account_user.ex` | ✓ Created (role enum: admin/member, no default) |
| `lib/billwatch/bills/category.ex` | ✓ Created (with hex color validation) |
| `test/support/fixtures/users_fixtures.ex` | ✓ Refactored (builder pattern: with_password, with_token_authenticated_at, with_confirmation_token) |
| `test/support/fixtures/accounts_fixtures.ex` | ✓ Rewritten (Account fixtures only) |
| `test/support/fixtures/account_users_fixtures.ex` | ✓ Created |
| `test/support/fixtures/categories_fixtures.ex` | ✓ Created |
| `test/support/fixtures/scope_fixtures.ex` | ✓ Created (scope with preloaded associations) |
| `test/support/token_helpers.ex` | ✓ Created (token manipulation utilities for tests) |
| `test/support/conn_case.ex` | ✓ Modified (imports TokenHelpers) |
| `test/support/data_case.ex` | ✓ Modified (imports TokenHelpers) |
| `test/billwatch/accounts/account_test.exs` | ✓ Created (7 tests) |
| `test/billwatch/accounts/account_user_test.exs` | ✓ Created (10 tests) |
| `test/billwatch/bills/category_test.exs` | ✓ Created (12 tests) |
| `lib/billwatch/accounts/scope.ex` | ✓ Modified (account/role fields, chainable API: new, for_user, for_account, with_role) |
| `lib/billwatch/accounts/invite_code.ex` | Pending |
| `lib/billwatch_web/components/auth_components.ex` | Pending |
| `lib/billwatch_web/live/landing_live.ex` | Pending |
| `lib/billwatch_web/live/calendar_live.ex` | Pending |
| `config/config.exs` | ✓ No changes needed |
| `config/runtime.exs` | ✓ Fixed pragma_foreign_keys |
| `config/dev.exs` | ✓ Fixed pragma_foreign_keys |
| `config/test.exs` | ✓ Fixed pragma_foreign_keys |

## Current State

- ✓ Phase 1 Complete: Base auth with email/password, confirmation flow
- ✓ Phase 2 Complete: Account, AccountUser, Category schemas created with migrations
- ✓ Phase 3 Complete: Scope extended with account/role fields and chainable API
- ✓ Phase 5 Complete: Registration transaction and helper functions in Accounts context
- ✓ Phase 6.1 Complete: UserAuth now builds full scope with account/role

### Recent Refactoring (Jan 13, 2026):
- ✓ User schema: Changed from `has_many :account_users` to `has_one :account_user` (with unique constraint)
- ✓ Scope module: Chainable API with `Scope.new() |> for_user() |> for_account() |> with_role()`
- ✓ UserAuth module: Major refactoring
  - Renamed functions for clarity (reissue_user_token_if_expired, load_user_token, put_remember_me_in_cookie, etc.)
  - Public methods grouped at top of module
  - Combined pattern-matched functions into single functions with conditionals
  - Simplified logic using `get_in` for nested params
- ✓ Test organization improved:
  - Created `TokenHelpers` module (test/support/token_helpers.ex) for token manipulation utilities
  - Created `ScopeFixtures` module (test/support/fixtures/scope_fixtures.ex)
  - Refactored fixtures to builder pattern (with_password, with_token_authenticated_at, with_confirmation_token)
  - Fixed confirmation token flow to properly use Base64-encoded tokens
- ✓ UserToken.build_email_token: Now accepts optional token parameter for testing
- ✓ All 93 tests passing
- ✓ Project compiles cleanly with no warnings
- ✓ Fixed SQLite3 pragma configuration (using pragma_foreign_keys: :on)
- Migrations created but **NOT YET RUN** (waiting for full implementation)
- **Next step**: Phase 4 (Invite Code) or Phase 6.2 (require_confirmed plug) or Phase 7 (Landing Page)

## UserAuth Function Renamings (Reference)

For clarity and consistency, the following function renamings were applied to `lib/billwatch_web/user_auth.ex`:

- `maybe_reissue_user_session_token` → `reissue_user_token_if_expired`
- `ensure_user_token` → `load_user_token`
- `write_remember_me_cookie` → `put_remember_me_in_cookie`
- `maybe_write_remember_me_cookie` → Combined into `put_remember_me_in_cookie` using `get_in` with default
- `maybe_store_return_to` → `store_return_to` (combined with conditional logic)
- `recreate_session_for_different_user` → `create_session_for_user` (combined both cases)

## To Resume

Run `mix compile` to verify state, then continue with remaining phases.

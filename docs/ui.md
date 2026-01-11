# UI Specification

## Overview

This document specifies UI functionality for BillWatch. For visual styling, colors, and layout details, refer to the attached design files (`home.jsx`, `calendar.jsx`).

---

## Pages Overview

| Page | Access | Purpose |
|------|--------|---------|
| Landing (`/`) | Public | Marketing page with auth modals |
| Calendar (`/`) | Authenticated | Main app — year calendar view |
| Settings (`/settings`) | Admin only | Account, members, categories |
| Profile (`/profile`) | Authenticated | User settings, leave account |

---

## Landing Page

**Components:**
- Nav: Logo, "Log in" button, "Sign up" button
- Hero: Headline, subhead, CTA button
- Footer: Copyright

**Modals triggered from landing:**
- Login
- Sign Up
- Forgot Password

---

## Auth Modals

### Login

- Email input
- Password input
- "Forgot password?" link
- Submit button
- Link to Sign Up

### Sign Up

- Email input
- Password input
- **Invite code input** *(missing in design)*
- Submit button
- Link to Login

### Forgot Password

**Initial state:**
- Email input
- Submit button
- Link to Login

**After submit:**
- Success message
- "Back to login" button

### Invited User Registration (`/register?token=xxx`)

- Email input (readonly, pre-filled)
- Password input
- Submit button

**Token validation (on page load):**

| Token Status | Behavior |
|--------------|----------|
| Valid | Show form |
| Invalid | Error: "This invitation link is invalid." |
| Expired | Error: "This invitation has expired. Please contact your account administrator for a new invite." |
| Already used | Error: "This invitation has already been used." + link to login |

---

## Calendar Page

### Header

- Hamburger menu button (indicator dot when filters active)
- Year navigation: previous/next buttons with year display
- Monthly total display
- "+ Create bill" button

### Calendar Grid

- 365-day continuous grid
- Each cell shows: month label (1st only), day name, day number
- Bills displayed as colored labels (category color)
- Click cell with bills → opens Day Detail modal

**Bill overflow display:**

| Bills Count | Display |
|-------------|---------|
| 1 | Single label |
| 2 | Two stacked labels |
| 3+ | First label + "+N more" |

**Empty calendar:** Show empty grid (no placeholder message)

### Slide-out Menu

**Sections:**

1. **Categories**
   - Filter buttons (toggle on/off)
   - Clear filters button (when filters active)
   - Shows bill count per category

2. **Account**
   - Settings (admin only)
   - Help & Support
   - Log out

3. **Footer**
   - Monthly total
   - Yearly total

### Day Detail Modal

- Header: Weekday, date, close button
- Bill list with:
  - Avatar (initials, category color background)
  - Name
  - Category dot + frequency
  - Price (if set)
  - Delete button
- Total (if multiple bills with prices)

**Interactions:**
- Click bill row → opens Edit Bill modal *(missing in design)*
- Click delete → confirmation, then delete

### Add/Edit Bill Modal

| Field | Required | Notes |
|-------|----------|-------|
| Name | Yes | Free text input |
| URL | No | Website URL *(missing in design)* |
| Amount | No | Decimal input |
| Frequency | Yes | Monthly, Yearly, Once *(design shows Quarterly — replace with Once)* |
| Category | Yes | Select from account categories |
| Due date | Yes | Date picker |

**Edit mode:** Same form, pre-filled with current values

---

## Settings Pages (Admin only)

### Account Tab

- Account name input
- Save button

### Members Tab

**Active members table:**

| Column | Notes |
|--------|-------|
| Email | |
| Role | Admin / Member badge |
| Status | "Active" |
| Actions | Change role, Remove (not for self) |

**Invitations table:**

| Column | Notes |
|--------|-------|
| Email | |
| Role | |
| Status | "Pending" (with expiry) or "Expired" |
| Actions | Resend, Revoke |

**Invite form:**
- Email input
- Role select
- Send button

### Categories Tab

- Category list: color, name, edit/delete buttons
- Add form: name, color picker
- **Delete flow:** Must select target category to reassign bills before deletion

---

## Profile Page

- Email (readonly)
- Change password section
- "Leave account" button
  - Blocked if last admin

---

## Design Gaps

Items in spec but missing from provided designs:

| Item | Where to Add |
|------|--------------|
| Invite code field | Sign Up modal |
| URL field | Add/Edit Bill modal |
| "Once" frequency | Frequency dropdown (replace Quarterly) |
| Edit bill modal | Same as Add modal, pre-filled |
| Bill row click → edit | Day Detail modal |
| Invalid/expired token pages | Error page templates |
| Settings pages | Full UI needed |
| Profile page | Full UI needed |

**Other design updates needed:**
- Bill avatars use initials (no logos)
- Category is required (not optional)
- Empty calendar shows empty grid (no placeholder)

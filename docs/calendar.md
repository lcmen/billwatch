# Calendar Feature Specification

## Overview

Year-at-a-glance calendar displaying all bills as colored labels on their due dates. Users can filter by category, navigate between years, and manage bills directly from the calendar.

---

## Domain

### Bill

| Field | Type | Storage | Notes |
|-------|------|---------|-------|
| id | uuid | DB | PK |
| account_id | uuid | DB | FK → accounts, required |
| category_id | uuid | DB | FK → categories, required |
| name | string | DB | required |
| url | string | DB | optional, website URL for the service |
| price | decimal | DB | nullable (for payment reminders without amount) |
| schedule_ical | string | DB | iCalendar RRULE format |
| active | boolean | DB | default: true |
| occurrences | list(date) | virtual | computed from schedule_ical for given year |
| monthly_price | decimal | virtual | price ÷ 12 for yearly, else price |

**Bill avatar:** Generated from bill name initials (gravatar-style), displayed with category color background. No logo storage needed.

### Category

Scoped to account.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid | PK |
| account_id | uuid | FK → accounts, required |
| name | string | required |
| color | string | hex, e.g., `"#ef4444"` |

**Default seeds** (created on account registration):

| Name | Color | Example Bills |
|------|-------|---------------|
| Housing | `#ef4444` | Rent, mortgage |
| Utilities | `#f59e0b` | Electric, gas, internet, phone |
| Insurance | `#8b5cf6` | Car, health, home |
| Subscriptions | `#10b981` | Netflix, Spotify, iCloud |
| Finance | `#3b82f6` | Credit cards, loans |
| Other | `#6b7280` | Miscellaneous |

**Category deletion behavior:**
- Admin must select a target category to reassign bills before deletion
- All bills in the deleted category are reassigned to the selected category
- Cannot delete if it's the last category (must have at least one)
- `category_id` on bills is never null

---

## Schedule Format

Store recurrence as iCalendar strings using the Cocktail library.

| Type | Format Example |
|------|----------------|
| Monthly | `DTSTART:20250115\nRRULE:FREQ=MONTHLY` |
| Yearly | `DTSTART:20250115\nRRULE:FREQ=YEARLY` |
| One-time | `DTSTART:20250115` (no RRULE) |

### Building Schedules

```elixir
def build_schedule(start_date, cycle, end_date \\ nil)
# cycle: :once | :monthly | :yearly
# end_date: optional, for finite recurrence
# Returns iCalendar string
```

### Expanding Occurrences

```elixir
def compute_occurrences(schedule_ical, year)
# Returns list of dates within the given year
# Handles edge cases: Dec 31 spanning to Jan 1, etc.
```

---

## Context Functions

### Queries

```elixir
def list_bills_for_calendar(account_id, year, category_ids \\ [])
# Returns bills with virtual fields (occurrences, monthly_price) populated
# If category_ids empty, returns all bills
# If category_ids provided, filters to those categories

def build_calendar(bills)
# Returns %{date => [bills]} map for efficient lookup
# Each date key has list of bills occurring on that date

def monthly_total(bills)
# Sums monthly_price across all bills
# Yearly bills: price ÷ 12
# Monthly/once bills: price as-is
# Nil prices: treated as 0

def list_categories(account_id)
# Returns all categories for account, ordered by name
```

### Commands

```elixir
def create_bill(account_id, attrs)
# attrs: %{name, url, price, category_id, start_date, cycle}
# name: required
# url: optional
# category_id: required
# Generates schedule_ical from start_date + cycle
# Returns {:ok, bill} or {:error, changeset}

def update_bill(bill_id, account_id, attrs)
# All fields editable: name, url, price, category_id, start_date, cycle, active
# Regenerates schedule_ical if date/cycle changed
# Returns {:ok, bill} or {:error, changeset}

def delete_bill(bill_id, account_id)
# Hard delete
# Returns :ok or {:error, :not_found}
```

---

## Bill Schema

### Stored Fields

```elixir
schema "bills" do
  field :name, :string
  field :url, :string
  field :price, :decimal
  field :schedule_ical, :string
  field :active, :boolean, default: true
  
  belongs_to :account, Account, type: :binary_id
  belongs_to :category, Category, type: :binary_id
  
  timestamps()
end
```

### Virtual Fields

```elixir
field :occurrences, {:array, :date}, virtual: true
field :monthly_price, :decimal, virtual: true
```

### Key Functions

```elixir
def with_computed_fields(bill_or_bills, year)
# Populates virtual fields after query
# Handles both single bill and list of bills
# Returns bill(s) with occurrences and monthly_price set
```

---

## LiveView

### State (Assigns)

| Assign | Type | Description |
|--------|------|-------------|
| year | integer | Currently viewed year |
| bills | list(Bill) | With virtual fields populated |
| calendar | map | `%{date => [bills]}` for efficient lookup |
| total_monthly | Decimal | Sum of monthly_price for header |
| selected_categories | list(uuid) | Active category filters (empty = all) |
| categories | list(Category) | For filter UI |
| current_account | Account | From auth scope |
| current_role | atom | `:admin` or `:member` |

### Events

| Event | Payload | Action |
|-------|---------|--------|
| `prev_year` | — | Decrement year, reload data |
| `next_year` | — | Increment year, reload data |
| `toggle_category` | `%{id: uuid}` | Toggle filter, reload data |
| `clear_filters` | — | Reset selected_categories to [], reload |
| `show_day` | `%{date: date}` | Open day detail modal |
| `show_add_bill` | — | Open add bill modal |
| `show_edit_bill` | `%{id: uuid}` | Open edit bill modal |
| `create_bill` | `%{...attrs}` | Insert bill, close modal, reload |
| `update_bill` | `%{id: uuid, ...attrs}` | Update bill, close modal, reload |
| `delete_bill` | `%{id: uuid}` | Remove bill, reload |

### Data Loading

Triggered on mount and after any data-changing event:

```elixir
def load_calendar_data(socket) do
  %{year: year, selected_categories: cats, current_account: account} = socket.assigns
  
  bills = Bills.list_bills_for_calendar(account.id, year, cats)
  calendar = Bills.build_calendar(bills)
  total = Bills.monthly_total(bills)
  
  assign(socket, bills: bills, calendar: calendar, total_monthly: total)
end
```

---

## UI Components

### Header

```
┌─────────────────────────────────────────────────────────────┐
│ [☰]  ◂ 2026 ▸                      $3,489/mo    [+ Add Bill]│
└─────────────────────────────────────────────────────────────┘
```

| Element | Behavior |
|---------|----------|
| Hamburger `☰` | Opens slide-out menu; orange dot when filters active |
| Year nav | `◂` decrements, `▸` increments year |
| Monthly total | Sum of all bills' monthly_price |
| Add Bill button | Opens add bill modal (orange/primary color) |

### Calendar Grid

**Layout:** CSS Grid with `grid-template-columns: repeat(auto-fill, minmax(70px, 1fr))`. Continuous 365-day flow (no month separations).

**Cell structure:**
```
┌──────────┐
│ Jan  MON │  ← Month label (1st only), day name
│    1     │  ← Day number
│ ████████ │  ← Bill label (category color)
│ ████████ │  ← Bill label
│ +2 more  │  ← Overflow indicator
└──────────┘
```

**Cell backgrounds:**

| Condition | Background | Additional |
|-----------|------------|------------|
| Today | `#fff7ed` | Orange ring/border |
| 1st of month | `#fef9e7` | Subtle highlight |
| Weekend | `#fafafa` | Slight gray |
| Default | `white` | — |

**Bill display logic:**

| Count | Display |
|-------|---------|
| 0 | Empty cell |
| 1 | Single label |
| 2 | Both labels stacked |
| 3+ | First label + "+N more" link |

**Bill label styling:**
- Background: category color
- Text: white or dark (based on color contrast)
- Truncated with ellipsis if too long
- Click opens day detail modal

### Hamburger Menu (Slide-out, 280px)

```
┌────────────────────────────┐
│ Categories           [✕]  │  ← Clear filters (if active)
├────────────────────────────┤
│ ● Housing          (12)   │  ← Color dot, name, count
│ ● Utilities         (8)   │
│ ● Subscriptions    (15)   │  ← Selected: full bg color
│ ● ...                     │
├────────────────────────────┤
│ Account                   │
│   Settings                │  ← Admin only
│   Help & Support          │
│   Log out                 │
├────────────────────────────┤
│ $3,489/mo · $41,868/yr    │  ← Totals footer
└────────────────────────────┘
```

**Category buttons:**
- Unselected: white bg, color dot, name, count badge
- Selected: category color bg, white text
- Clicking toggles filter

**Clear filters button:** Only shown when filters are active.

### Day Detail Modal

Triggered by clicking a cell with bills.

```
┌────────────────────────────────────────────┐
│ Thursday, January 15                    ✕  │
├────────────────────────────────────────────┤
│ [N] Netflix              ● Monthly   $15   │  ← Logo/avatar, name, cycle, price
│                                      [🗑]  │  ← Delete button
├────────────────────────────────────────────┤
│ [S] Spotify              ● Monthly   $10   │
│                                      [🗑]  │
├────────────────────────────────────────────┤
│                              Total:  $25   │  ← Only if multiple bills with prices
└────────────────────────────────────────────┘
```

| Element | Behavior |
|---------|----------|
| Logo/avatar | Clearbit logo or initial letter in category color |
| Category dot | Small colored circle |
| Cycle | "Monthly", "Yearly", or "One-time" |
| Price | Formatted with currency; "—" if nil |
| Delete button | Confirmation required |
| Row click | Opens edit bill modal |

### Add/Edit Bill Modal

```
┌────────────────────────────────────────────┐
│ Add Bill / Edit Bill                    ✕  │
├────────────────────────────────────────────┤
│ Name *                                     │
│ [Netflix________________________]          │
├────────────────────────────────────────────┤
│ URL (optional)                             │
│ [https://netflix.com____________]          │
├────────────────────────────────────────────┤
│ Amount (optional)                          │
│ [$][15.00___________________________]      │
├────────────────────────────────────────────┤
│ Frequency *                                │
│ [Monthly ▾]                                │  ← Monthly, Yearly, Once
├────────────────────────────────────────────┤
│ Category *                                 │
│ [Subscriptions ▾]                          │
├────────────────────────────────────────────┤
│ Due date *                                 │
│ [📅 January 15, 2026]                      │
├────────────────────────────────────────────┤
│                    [Cancel]  [Save Bill]   │
└────────────────────────────────────────────┘
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Name | text input | Yes | Whatever user types becomes the bill name |
| URL | text input | No | Website URL for the service |
| Amount | number input | No | Allows payment reminders without amount |
| Frequency | select | Yes | Monthly, Yearly, Once |
| Category | select | Yes | Must select a category |
| Due date | date picker | Yes | Start date for recurrence |

**Edit mode differences:**
- Pre-fills all fields with current values
- "Save Bill" becomes "Update Bill"
- All fields remain editable

---

## Database Schema

### categories

```elixir
create table(:categories, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
  add :name, :string, null: false
  add :color, :string, null: false

  timestamps()
end

create index(:categories, [:account_id])
create unique_index(:categories, [:account_id, :name])  # Prevent duplicate names per account
```

### bills

```elixir
create table(:bills, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
  add :category_id, references(:categories, type: :binary_id, on_delete: :restrict), null: false
  add :name, :string, null: false
  add :url, :string
  add :price, :decimal
  add :schedule_ical, :string, null: false
  add :active, :boolean, default: true, null: false

  timestamps()
end

create index(:bills, [:account_id, :active])
create index(:bills, [:category_id])
```

**Note:** `on_delete: :restrict` prevents category deletion if bills exist. Admin must reassign bills first.

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Bill spans year boundary | Show in both years where it occurs |
| Category deleted | Admin must reassign bills to another category first (deletion blocked until done) |
| Bill with no price | Displayed without amount; excluded from totals (treated as $0) |
| 29 Feb (leap year) | Shown only in leap years; Cocktail handles this |
| Very long bill name | Truncate with ellipsis in calendar cell |
| Many bills on one day | Show first + "+N more" overflow indicator |
| Empty calendar (no bills) | Show empty grid (no placeholder message) |

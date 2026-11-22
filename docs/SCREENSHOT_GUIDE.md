# Screenshot Guide — Spendly

> This guide explains every screen in the Spendly application and provides instructions for capturing screenshots for the README documentation.

---

## How to Capture Screenshots

### Android (Physical Device or Emulator)
```bash
# Start the app
cd frontend
flutter run

# Capture screenshot via ADB
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png docs/screenshots/<page_name>.png
```

### Flutter DevTools
```bash
flutter run --profile
# Press "s" in the terminal to save a screenshot
```

### VS Code / Android Studio
Use the built-in screenshot button in the device toolbar while the app is running.

---

## Required Screenshots

Place all screenshots in `docs/screenshots/` with the exact filenames listed below.

| Filename | Screen | Description |
|----------|--------|-------------|
| `splash.png` | Splash Screen | Animated logo + loading indicator on startup |
| `login.png` | Login Screen | Email/password form + Google Sign-In button |
| `register.png` | Register Screen | Name, email, password registration form |
| `forgot_password.png` | Forgot Password | Email input for password reset via Firebase |
| `dashboard.png` | Dashboard | Monthly total, donut chart, recent transactions |
| `history.png` | Transaction History | Full list of expenses with filter/search |
| `add_expense.png` | Add Expense | Form to add new expense with category picker |
| `edit_expense.png` | Edit Expense | Pre-filled form to edit an existing expense |
| `expense_detail.png` | Expense Detail | Modal showing full transaction details |
| `report.png` | Analytics Report | Bar chart + category breakdown + monthly stats |
| `profile.png` | Profile | User info, avatar picker, logout |
| `avatar_picker.png` | Avatar Picker | Animated avatar selection sheet |

---

## Screen Descriptions

### 1. Splash Screen (`splash.png`)
- **Route:** App startup (before auth check)
- **Purpose:** Branding screen shown while `AuthProvider.checkAuthStatus()` validates the stored session token
- **Key Elements:** Spendly logo, app name, tagline, loading spinner
- **Duration:** Shown until session check completes

### 2. Login Screen (`login.png`)
- **Route:** `LoginScreen` → shown when no valid session exists
- **Purpose:** Authenticates user via email/password (Laravel Sanctum) or Google Sign-In (Firebase)
- **Key Elements:**
  - Email text field with validation
  - Password field with show/hide toggle
  - "Lupa Sandi?" link to Forgot Password
  - "Masuk Sekarang" primary button (disabled during loading)
  - Google Sign-In button
  - Link to Register screen
  - Server IP configuration for mobile testing
- **Validation:** Email format check, minimum 6-character password
- **On success:** Navigates to Dashboard (via `SplashScreenWrapper` reactive routing)

### 3. Register Screen (`register.png`)
- **Route:** `RegisterScreen` → accessed from Login screen
- **Purpose:** Creates a new user account directly in the Laravel backend
- **Key Elements:**
  - Full name field
  - Email field
  - Password field (min 6 chars)
  - Confirm password field
  - "Daftar Sekarang" button
- **On success:** Account created, token saved, navigates to Dashboard

### 4. Forgot Password Screen (`forgot_password.png`)
- **Route:** `ForgotPasswordScreen` → accessed from Login screen
- **Purpose:** Sends a password reset link via Firebase to the user's email
- **Key Elements:**
  - Email input field
  - "Kirim Link Reset" button
  - Success confirmation message
- **Backend:** Firebase `sendPasswordResetEmail()`

### 5. Dashboard Screen (`dashboard.png`)
- **Route:** Home tab (index 0) of `MainNavigationScreen`
- **Purpose:** Financial overview for the selected month
- **Key Elements:**
  - `BalanceCard` — total monthly expenses display with balance visibility toggle
  - `CategoryDonutChart` — donut chart showing expense distribution by category
  - `CategoryCardList` — horizontal scrollable category spending cards
  - `RecentTransactionsList` — last 5 transactions
  - Month/year navigator
  - FAB button "Tambah Pengeluaran"
- **API:** `GET /api/dashboard?month=&year=`

### 6. Transaction History Screen (`history.png`)
- **Route:** History tab (index 1) of `MainNavigationScreen`
- **Purpose:** Full list of all user expenses with filtering capabilities
- **Key Elements:**
  - Month/year filter
  - Category filter chips
  - Search bar
  - `TransactionItem` list tiles (date, title, category icon, amount)
  - Total amount summary
- **API:** `GET /api/expenses?month=&year=&category_id=&search=`

### 7. Add Expense Screen (`add_expense.png`)
- **Route:** `AddExpenseScreen` → opened from FAB button
- **Purpose:** Create a new expense transaction
- **Key Elements:**
  - Category picker grid with icons
  - Title text field
  - Amount field (numeric, Indonesian Rupiah)
  - Date picker
  - Notes text area
  - "Simpan Pengeluaran" button
- **API:** `POST /api/expenses`

### 8. Edit Expense Screen (`edit_expense.png`)
- **Route:** `EditExpenseScreen` → accessed from expense detail
- **Purpose:** Modify an existing expense transaction
- **Key Elements:** Same fields as Add Expense, pre-filled with existing data
- **API:** `PUT /api/expenses/{id}`

### 9. Expense Detail Modal (`expense_detail.png`)
- **Route:** `ExpenseDetailModal` → bottom sheet from transaction tap
- **Purpose:** View full details of a transaction with edit/delete actions
- **Key Elements:**
  - Category icon and color
  - Full title and notes
  - Amount in Rupiah format
  - Date
  - Edit button → Edit Expense screen
  - Delete button with confirmation dialog
- **API:** `DELETE /api/expenses/{id}`

### 10. Analytics Report Screen (`report.png`)
- **Route:** Reports tab (index 2) of `MainNavigationScreen`
- **Purpose:** Detailed financial analytics and spending trends
- **Key Elements:**
  - Month/year selector
  - `SpendingBarChart` — bar chart of daily spending for selected month
  - Monthly trend comparison (current vs previous month, percentage change)
  - Average daily expense
  - Highest single expense
  - Category breakdown with percentages
- **API:** `GET /api/reports?month=&year=`

### 11. Profile Screen (`profile.png`)
- **Route:** Profile tab (index 3) of `MainNavigationScreen`
- **Purpose:** View and edit user profile information
- **Key Elements:**
  - `AppAvatar` — displays user avatar (animated preset, uploaded photo, or initials)
  - User name and email
  - Edit name, email, password fields
  - Avatar picker button → opens `AvatarPickerSheet`
  - Upload custom photo from gallery
  - Remove avatar option
  - Logout button
- **API:** `GET /api/user`, `PUT /api/user`, `POST /api/user/avatar`

### 12. Avatar Picker Sheet (`avatar_picker.png`)
- **Route:** `AvatarPickerSheet` → bottom sheet from Profile screen
- **Purpose:** Select an animated avatar preset for the user profile
- **Key Elements:**
  - Grid of animated avatar options (defined in `animated_avatar_data.dart`)
  - Upload custom photo option
  - Remove avatar / reset to initials option
- **API:** `PUT /api/user` with `avatar` key (animated preset identifier)

---

## Recommended Screenshot Dimensions

- **Mobile portrait:** 390 × 844 px (iPhone 14 size) or 1080 × 2400 px (Android FHD)
- **Format:** PNG
- **Quality:** High resolution, no compression
- **Data:** Use realistic but non-sensitive demo data (e.g., generic expense names like "Makan Siang", "Transportasi")

## Privacy Requirements

Before uploading screenshots:
- ✅ Use demo/test account data only
- ❌ No real names, emails, or personal information
- ❌ No real financial amounts tied to real transactions
- ❌ No authentication tokens visible

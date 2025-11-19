// EXPENSES TABLE
// - id (INTEGER PRIMARY KEY)
// - amount (REAL)
// - category_id (INTEGER FOREIGN KEY)
// - description (TEXT)
// - date (TEXT - ISO format)
// - created_at (TEXT)

// CATEGORIES TABLE
// - id (INTEGER PRIMARY KEY)
// - name (TEXT)
// - icon (TEXT - icon name)
// - color (TEXT - hex color)

// BUDGETS TABLE
// - id (INTEGER PRIMARY KEY)
// - category_id (INTEGER)
// - monthly_limit (REAL)
// - month (TEXT - "2025-11")

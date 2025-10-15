You are a Senior Full Stack Developer specializing in Flutter + Stock PHP + MySQL.

You are to build a complete enterprise-level system named:
**Tupi Supreme Activated Carbon Plant Monitoring System (TSACI System)**

---

## 🎯 PROJECT OVERVIEW
Tupi Supreme Coco Ventures Inc. (TSACI) operates a coconut processing plant that produces:
- Coconut Water Concentrate
- Coconut Cream
- Crude Coconut Oil
- RBD Coconut Oil (Refined, Bleached, Deodorized)
- Coconut Husk Chips
- Coconut Pit (for Horticulture)
- Activated Carbon (Granulated and Charcoal Dust)

The goal of this system is to **monitor production operations, inventory, sales, and expenses in real-time**, and to provide **data visualization dashboards** for management.

---

## ⚙️ TECHNOLOGY STACK

**Frontend:**
- Flutter SDK (Mobile + Web + Desktop)
- Integrates with REST API using HTTP package
- Uses Chart packages (`fl_chart`, `syncfusion_flutter_charts`)
- Tailwind-inspired UI components (built in Flutter)

**Backend:**
- Stock PHP OOP with Controllers (no frameworks)
- Follows MVC structure
- Authentication via JWT
- REST API endpoints returning JSON

**Database:**
- MySQL (using PDO for secure parameterized queries)

**Design System:**
- Custom Tailwind-inspired Flutter widgets
- Clean, minimal UI similar to "Flowbite Admin Template"
- Includes Dashboard, Tables, Forms, and Modals
- Supports Dark/Light mode

---

## 🗂️ FOLDER STRUCTURE

/backend
┣ 📁 config/
┃ ┗ db.php
┣ 📁 controllers/
┃ ┣ AuthController.php
┃ ┣ ProductionController.php
┃ ┣ InventoryController.php
┃ ┣ SalesController.php
┃ ┣ ExpenseController.php
┃ ┣ ReportController.php
┃ ┣ ProductController.php
┃ ┣ CustomerController.php
┃ ┗ SupplierController.php
┣ 📁 models/
┃ ┣ User.php
┃ ┣ Production.php
┃ ┣ Inventory.php
┃ ┣ Sale.php
┃ ┣ Expense.php
┃ ┣ Product.php
┃ ┣ Customer.php
┃ ┗ Supplier.php
┣ 📁 middleware/
┃ ┗ jwt_auth.php
┣ 📁 core/
┃ ┗ Router.php
┣ 📁 helpers/
┃ ┗ response.php
┣ 📁 database/
┃ ┗ schema.sql
┣ 📁 vendor/
┃ ┗ firebase/php-jwt
┗ index.php

/lib (Flutter)
┣ 📁 core/
┃ ┣ constants/
┃ ┃ ┣ app_colors.dart
┃ ┃ ┣ app_styles.dart
┃ ┃ ┗ api_constants.dart
┃ ┣ theme/
┃ ┃ ┗ app_theme.dart
┃ ┗ widgets/
┃   ┣ app_button.dart
┃   ┣ app_card.dart
┃   ┣ app_scaffold.dart
┃   ┗ widgets.dart
┣ 📁 models/
┃ ┣ user_model.dart
┃ ┣ production_model.dart
┃ ┣ dashboard_model.dart
┃ ┗ product_model.dart
┣ 📁 services/
┃ ┣ api_service.dart
┃ ┣ auth_service.dart
┃ ┣ storage_service.dart
┃ ┣ dashboard_service.dart
┃ ┗ offline/
┃   ┣ offline_storage_service.dart
┃   ┗ sync_service.dart
┣ 📁 screens/
┃ ┣ auth/
┃ ┃ ┗ login_screen.dart
┃ ┣ manager/
┃ ┃ ┣ manager_home_screen.dart
┃ ┃ ┣ production_report_screen.dart
┃ ┃ ┣ sales_report_screen.dart
┃ ┃ ┗ expense_report_screen.dart
┃ ┣ supervisor/
┃ ┃ ┣ supervisor_home_screen.dart
┃ ┃ ┗ add_production_screen.dart
┃ ┗ admin/
┃   ┣ admin_home_screen.dart
┃   ┣ user_management_screen.dart
┃   ┣ product_management_screen.dart
┃   ┣ inventory_management_screen.dart
┃   ┣ sales_management_screen.dart
┃   ┗ expense_management_screen.dart
┣ 📁 utils/
┃ ┗ app_router.dart
┗ main.dart

---

## 🧩 BACKEND REQUIREMENTS

### 1. Authentication (JWT)
- `/api/auth/login`
- `/api/auth/register`
- `/api/auth/verify`
- `/api/auth/profile`
- Use `firebase/php-jwt` for token generation
- Passwords must be hashed using `password_hash()`

### 2. Production Monitoring
- Endpoint: `/api/production`
- Functions:
  - Add production log (date, supervisor, product type, input qty, output qty)
  - Fetch all production logs
  - Filter by date range or product type
  - Update and delete production logs

### 3. Inventory Management
- Endpoint: `/api/inventory`
- Functions:
  - Add stock
  - Update stock levels after production or sales
  - Fetch current stock
  - Trigger low stock alert if below minimum threshold
  - Get inventory by product

### 4. Sales Module
- Endpoint: `/api/sales`
- Record customer orders, amount, and status
- Auto-update inventory after sale
- Filter by date range
- Update sale status

### 5. Expenses Module
- Endpoint: `/api/expenses`
- CRUD operations for expenses (fuel, maintenance, electricity, etc.)
- Categorized by department
- Filter by date range and category

### 6. Reports & Dashboard
- `/api/reports/monthly` - Monthly report
- `/api/reports/dashboard` - Dashboard summary
- `/api/reports/production-summary` - Production efficiency
- Return:
  - Total production volume by product
  - Monthly sales vs. expenses
  - Income summary & profit margin
  - Stock levels summary
  - Top selling product
  - Low stock alerts

### 7. Product Management
- Endpoint: `/api/products`
- CRUD operations for products
- Filter by category

### 8. Customer Management
- Endpoint: `/api/customers`
- CRUD operations for customers

### 9. Supplier Management
- Endpoint: `/api/suppliers`
- CRUD operations for suppliers

---

## 📱 FLUTTER FRONTEND REQUIREMENTS

### Universal Features (All Roles):
- Tailwind-inspired UI components
- JWT authentication
- Role-based routing
- Responsive design (mobile, tablet, web, desktop)
- Pull-to-refresh functionality
- Error handling & loading states
- Offline capability (for supervisors)

### Color Theme:
- Primary: `#2D6A4F` (Forest Green)
- Accent: `#40916C`
- Background: `#F8F9FA`
- Dark mode background: `#1A1A1A`

### Roles & Permissions:

#### 1. **Owner/Manager App (Mobile/Web)**
   - Login with JWT authentication
   - View Dashboard Analytics:
     - Total Income (monthly)
     - Total Expenses (monthly)
     - Net Income (profit)
     - Production logs count
     - Top selling product
     - Low stock alerts
   - View Reports:
     - Production Report (with date range filter)
     - Production Report (with product filter)
     - Sales Report
     - Expense Report
   - Filter by Date and Product Type
   - Pull-to-refresh for real-time data
   - Quick action buttons
   - Logout functionality

#### 2. **Supervisor App (Tablet)**
   - Login with JWT authentication
   - Supervisor Home Dashboard:
     - Online/Offline status indicator
     - Pending sync count badge
     - Manual sync button
   - Add Daily Production Data:
     - Select product (dropdown)
     - Choose production date
     - Enter input quantity (raw materials)
     - Enter output quantity (finished products)
     - Add optional notes
   - Offline Capability:
     - Save production data locally when offline
     - Auto-sync when connection restored
     - Manual sync option
     - View pending items count
   - Form validation
   - Connection status monitoring

#### 3. **Admin Dashboard (Web/Desktop)**
   - Full system management (via Flutter Web)
   - Manage Users, Products, Inventory, Sales, and Expenses
   - Access all reports and analytics
   - User administration
   - System configuration

---

## 🗃️ DATABASE STRUCTURE

**Database name:** `tsaci_db`

Tables:
- `users(user_id, name, email, role, password_hash, created_at, updated_at)`
- `products(product_id, name, category, price, unit, created_at, updated_at)`
- `production(production_id, product_id, supervisor_id, input_qty, output_qty, date, notes, created_at, updated_at)`
- `inventory(inventory_id, product_id, quantity, location, minimum_threshold, created_at, updated_at)`
- `sales(sale_id, customer_id, product_id, quantity, unit_price, total_amount, status, date, created_at, updated_at)`
- `expenses(expense_id, category, amount, date, description, department, created_at, updated_at)`
- `suppliers(supplier_id, name, contact, address, created_at, updated_at)`
- `customers(customer_id, name, contact, address, created_at, updated_at)`

Use `InnoDB`, all tables with proper foreign keys and timestamps.

**User Roles:**
- `owner` - Full system access
- `admin` - Full system access
- `manager` - View reports, manage operations (limited delete)
- `supervisor` - Add production logs only

---

## 🚀 DEVELOPMENT TASKS

1. ✅ Build MySQL Schema  
2. ✅ Create `db.php` PDO connection  
3. ✅ Build `Router.php` to handle all routes dynamically  
4. ✅ Implement JWT Auth  
5. ✅ Create all Controllers (CRUD endpoints)  
6. ✅ Create Flutter UI Components (Tailwind-inspired)
7. ✅ Connect Flutter frontend to PHP REST API  
8. ⏳ Implement Dashboard charts in Flutter  
9. ⏳ Test and deploy on VPS or hosting  

---

## ✅ OUTPUT EXPECTATION

Deliver a **fully functional backend + frontend prototype**:
- ✅ Backend PHP API (JWT secured) - 50+ endpoints
- ✅ Flutter mobile app for Owner/Manager
- ✅ Flutter mobile app for Supervisor with offline sync
- ✅ Universal Flutter UI system (works on mobile, web, desktop)
- ✅ Dashboard with real-time analytics
- ✅ Production reporting with filters
- ⏳ Data Visualization charts (sales vs. expenses, production graphs)

Make all code **clean, modular, and reusable**, with OOP principles and controller-based logic.

---

## 🔐 DEFAULT CREDENTIALS

**Admin Account:**
- Email: `admin@tsaci.com`
- Password: `admin123`

**Supervisor Account:**
- Email: `supervisor@tsaci.com`
- Password: `supervisor123`

---

## 📦 DEPENDENCIES

**Backend (PHP):**
- firebase/php-jwt: ^6.10

**Frontend (Flutter):**
- http: ^1.2.0
- shared_preferences: ^2.2.2
- intl: ^0.19.0
- connectivity_plus: ^6.0.2

**Optional for Charts:**
- fl_chart: ^0.x.x
- syncfusion_flutter_charts: ^x.x.x

---

## 🌐 API ENDPOINTS (50+ Total)

### Authentication (4)
- POST /api/auth/login
- POST /api/auth/register
- GET /api/auth/verify
- GET /api/auth/profile

### Production (7)
- GET /api/production
- GET /api/production/{id}
- POST /api/production
- PUT /api/production/{id}
- DELETE /api/production/{id}
- GET /api/production/filter/date
- GET /api/production/filter/product

### Inventory (6)
- GET /api/inventory
- GET /api/inventory/product/{id}
- GET /api/inventory/low-stock
- POST /api/inventory
- PUT /api/inventory/{id}
- DELETE /api/inventory/{id}

### Sales (7)
- GET /api/sales
- GET /api/sales/{id}
- POST /api/sales
- PUT /api/sales/{id}
- PUT /api/sales/{id}/status
- DELETE /api/sales/{id}
- GET /api/sales/filter/date

### Expenses (7)
- GET /api/expenses
- GET /api/expenses/{id}
- POST /api/expenses
- PUT /api/expenses/{id}
- DELETE /api/expenses/{id}
- GET /api/expenses/filter/date
- GET /api/expenses/filter/category

### Reports (3)
- GET /api/reports/monthly
- GET /api/reports/dashboard
- GET /api/reports/production-summary

### Products (6)
- GET /api/products
- GET /api/products/{id}
- POST /api/products
- PUT /api/products/{id}
- DELETE /api/products/{id}
- GET /api/products/filter/category

### Customers (5)
- GET /api/customers
- GET /api/customers/{id}
- POST /api/customers
- PUT /api/customers/{id}
- DELETE /api/customers/{id}

### Suppliers (5)
- GET /api/suppliers
- GET /api/suppliers/{id}
- POST /api/suppliers
- PUT /api/suppliers/{id}
- DELETE /api/suppliers/{id}

---

## 🎯 SYSTEM FEATURES

✅ **Backend Features:**
- RESTful API architecture
- JWT token authentication (7-day validity)
- Role-based access control
- Password hashing (bcrypt)
- SQL injection prevention (PDO)
- CORS support
- Error handling
- Auto inventory updates
- Low stock alerts

✅ **Frontend Features:**
- Cross-platform (iOS, Android, Web, Desktop)
- Tailwind-inspired UI components
- Offline data sync
- Pull-to-refresh
- Form validation
- Loading states
- Error handling
- Role-based routing
- Real-time analytics
- Date range filtering
- Product filtering

---

## 📊 CURRENT STATUS

**Backend:** 100% Complete ✅
**Frontend:** 90% Complete ✅
**Remaining:** Dashboard charts, Full Sales/Expense reports

**The system is production-ready for core operations!** 🚀

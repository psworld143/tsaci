# TSACI - Tupi Supreme Activated Carbon Plant Monitoring System

A complete enterprise-level plant monitoring system for coconut processing operations.

---

## 🎯 Overview

Tupi Supreme Coco Ventures Inc. (TSACI) operates a coconut processing plant producing:
- Coconut Water Concentrate
- Coconut Cream
- Crude & RBD Coconut Oil
- Coconut Husk Chips & Pit
- Activated Carbon (Granulated & Charcoal Dust)

This system monitors production operations, inventory, sales, and expenses in real-time with data visualization dashboards.

---

## ⚙️ Technology Stack

### Backend
- **PHP 7.4+** (Stock PHP OOP, MVC pattern)
- **MySQL** (PDO for secure queries)
- **JWT Authentication** (firebase/php-jwt)
- **REST API** (50+ endpoints)

### Frontend
- **Flutter SDK** (Mobile + Web + Desktop)
- **HTTP Package** (API integration)
- **Shared Preferences** (Local storage)
- **Connectivity Plus** (Offline detection)
- **Tailwind-inspired UI** (Custom Flutter components)

### Design
- Primary Color: `#2D6A4F` (Forest Green)
- Accent Color: `#40916C`
- Minimal, clean interface
- Dark/Light mode support

---

## 👥 User Roles (5 Official Roles)

### 1. Admin (Administrator)
- Full system access and control
- Manage all users and permissions
- System configuration and white labeling
- Access to all modules and reports
- Token expiry management

### 2. Production Manager
- **Complete production operations management**
- Create and schedule production batches
- Monitor batch progress across stages
- Approve raw material withdrawals
- Manage workers and provide feedback
- View production reports and analytics
- Export reports (PDF/Excel)
- Dedicated sidebar interface

### 3. Inventory Officer
- Manage stock and inventory control
- View inventory reports and alerts
- Track low stock items
- Manage product categories
- Export inventory reports

### 4. Quality Assurance Officer
- Quality control and testing
- Access QA reports and metrics
- Monitor product quality standards
- Track compliance metrics

### 5. Worker/Operator
- Add daily production logs
- Record raw materials used
- Record output products
- Basic operational tasks
- Offline data sync capability

---

### ⚠️ **Deprecated Roles** (Legacy - Backward Compatibility Only)
These roles are deprecated and redirect to new equivalents:
- `manager` → redirects to `production_manager`
- `owner` → redirects to `admin`
- `supervisor` → redirects to `worker`

**Note:** Use only the 5 official roles above for new users.

---

## 📱 Features

### Backend API (50+ Endpoints)
✅ JWT Authentication (login, register, verify)
✅ Production monitoring (CRUD + filters)
✅ Inventory management (auto-updates, low stock alerts)
✅ Sales tracking (auto inventory deduction)
✅ Expense management (categorized)
✅ Reports & analytics (monthly, dashboard, summaries)
✅ Product, customer, supplier management
✅ Role-based access control
✅ CORS support

### Flutter Frontend
✅ Cross-platform (iOS, Android, Web, Desktop)
✅ Tailwind-inspired UI components
✅ JWT authentication with local storage
✅ Role-based routing
✅ Dashboard with real-time analytics
✅ Production reports with filtering
✅ Date range and product filters
✅ Pull-to-refresh
✅ Offline data sync (for supervisors)
✅ Form validation & error handling

---

## 🗂️ Project Structure

```
tsaci/
├── backend/
│   ├── config/
│   │   └── db.php
│   ├── controllers/
│   │   ├── AuthController.php
│   │   ├── ProductionController.php
│   │   ├── InventoryController.php
│   │   ├── SalesController.php
│   │   ├── ExpenseController.php
│   │   ├── ReportController.php
│   │   ├── ProductController.php
│   │   ├── CustomerController.php
│   │   └── SupplierController.php
│   ├── models/
│   │   ├── User.php
│   │   ├── Production.php
│   │   ├── Inventory.php
│   │   ├── Sale.php
│   │   ├── Expense.php
│   │   ├── Product.php
│   │   ├── Customer.php
│   │   └── Supplier.php
│   ├── middleware/
│   │   └── jwt_auth.php
│   ├── core/
│   │   └── Router.php
│   ├── helpers/
│   │   └── response.php
│   ├── database/
│   │   └── schema.sql
│   ├── vendor/
│   └── index.php
│
└── lib/ (Flutter)
    ├── core/
    │   ├── constants/
    │   ├── theme/
    │   └── widgets/
    ├── models/
    ├── services/
    │   └── offline/
    ├── screens/
    │   ├── auth/
    │   ├── dashboard/
    │   ├── supervisor/
    │   └── reports/
    ├── utils/
    └── main.dart
```

---

## 🚀 Installation

### Prerequisites
- XAMPP (Apache + MySQL + PHP 7.4+)
- Flutter SDK 3.0+
- Composer

### Backend Setup

1. **Start XAMPP**
   - Start Apache and MySQL

2. **Create Database**
   ```bash
   mysql -u root
   CREATE DATABASE tsaci_db;
   ```

3. **Import Schema**
   ```bash
   cd /path/to/tsaci
   mysql -u root tsaci_db < backend/database/schema.sql
   ```

4. **Install Dependencies**
   ```bash
   cd backend
   composer install
   ```

5. **Configure Database**
   - Edit `backend/config/db.php` if needed (default: localhost, root, no password)

6. **Test API**
   ```bash
   php backend/test_api.php
   ```

### Flutter Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure API URL**
   - Edit `lib/core/constants/api_constants.dart`
   - Update `baseUrl` if needed (default: http://localhost/tsaci/backend/api)

3. **Run App**
   ```bash
   # Mobile
   flutter run
   
   # Web
   flutter run -d chrome
   
   # Desktop
   flutter run -d macos  # or windows/linux
   ```

---

## 🔐 Default Credentials

### Admin Account
- **Email:** admin@tsaci.com
- **Password:** admin123
- **Role:** Administrator

### Production Manager Account
- **Email:** manager@tsaci.com
- **Password:** manager123
- **Role:** Production Manager

### Inventory Officer Account
- **Email:** inventory@tsaci.com
- **Password:** inventory123
- **Role:** Inventory Officer

### QA Officer Account
- **Email:** qa@tsaci.com
- **Password:** qa123
- **Role:** Quality Assurance Officer

### Worker Account
- **Email:** worker@tsaci.com
- **Password:** worker123
- **Role:** Worker/Operator

⚠️ **IMPORTANT: Change all default passwords in production!**

---

## 📊 Database Schema

### Tables (8 total)
- `users` - User accounts & authentication
- `products` - Product catalog (8 coconut products)
- `production` - Production logs
- `inventory` - Stock management
- `sales` - Sales transactions
- `expenses` - Expense tracking
- `suppliers` - Supplier information
- `customers` - Customer information

All tables use InnoDB engine with proper foreign keys and timestamps.

---

## 🌐 API Endpoints

### Base URL
```
http://localhost/tsaci/backend/api
```

### Authentication
- POST `/auth/login` - User login
- POST `/auth/register` - User registration
- GET `/auth/verify` - Verify token
- GET `/auth/profile` - Get user profile

### Production
- GET `/production` - Get all production logs
- POST `/production` - Create production log
- GET `/production/filter/date?start_date=X&end_date=Y` - Filter by date
- GET `/production/filter/product?product_id=X` - Filter by product

### Inventory
- GET `/inventory` - Get all inventory
- GET `/inventory/low-stock` - Get low stock items
- POST `/inventory` - Add stock

### Reports
- GET `/reports/dashboard` - Dashboard summary
- GET `/reports/monthly?month=X&year=Y` - Monthly report
- GET `/reports/production-summary` - Production efficiency

*See `specifications.md` for complete API documentation*

---

## 🔧 Configuration

### Backend
- **Database:** `backend/config/db.php`
- **JWT Secret:** `backend/middleware/jwt_auth.php`
- **CORS:** `backend/.htaccess` and `backend/config/cors.php`

### Flutter
- **API URL:** `lib/core/constants/api_constants.dart`
- **Theme:** `lib/core/theme/app_theme.dart`
- **Colors:** `lib/core/constants/app_colors.dart`

---

## 📱 Offline Sync (Supervisors)

Supervisors can add production data offline:
1. App detects offline status
2. Data saved locally (SharedPreferences)
3. Badge shows pending items
4. Auto-syncs when connection restored
5. Manual sync button available

---

## 🎨 UI Components

Custom Tailwind-inspired Flutter widgets:
- `AppScaffold` - Page templates
- `AppCard` - Containers
- `AppButton` - Multiple variants
- `StatCard` - Dashboard widgets
- `AppTextField` - Form inputs
- `AppBadge` - Status indicators
- `AppEmptyState` - Empty states
- `AppLoadingState` - Loading indicators

---

## 🧪 Testing

### Backend API Test
```bash
cd backend
php test_api.php
```

### Flutter Test
```bash
flutter test
```

### Manual Testing
1. Login as admin
2. View dashboard
3. Add production log (as supervisor)
4. Test offline sync
5. View reports with filters

---

## 📈 System Status

✅ **Backend:** 100% Complete (50+ endpoints)
✅ **Frontend:** 90% Complete
⏳ **Remaining:** Dashboard charts, Full Sales/Expense reports

**The system is production-ready for core operations!**

---

## 🛠️ Technologies Used

- Flutter 3.9+
- PHP 7.4+
- MySQL 5.7+
- Composer
- firebase/php-jwt
- http (Flutter)
- shared_preferences (Flutter)
- connectivity_plus (Flutter)
- intl (Flutter)

---

## 📝 License

Proprietary - Tupi Supreme Coco Ventures Inc.

---

## 👨‍💻 Development

For detailed specifications, see `specifications.md`

For API documentation, test the endpoints using:
- Postman
- cURL
- Browser (GET endpoints)
- Flutter app

---

## 🚀 Deployment

### Production Checklist
- [ ] Change JWT secret key
- [ ] Update database credentials
- [ ] Restrict CORS origins
- [ ] Disable error display
- [ ] Enable HTTPS
- [ ] Change default passwords
- [ ] Set up backups
- [ ] Configure domain/hosting
- [ ] Test all endpoints
- [ ] Performance optimization

---

## 📞 Support

For issues or questions:
1. Check `specifications.md`
2. Review API endpoints
3. Test with `backend/test_api.php`
4. Check database schema

---

**TSACI System v1.0**  
Enterprise Plant Monitoring Solution

# TSACI Plant Monitoring System - Installation Guide

## 📋 Table of Contents
1. [System Requirements](#system-requirements)
2. [Installation Steps](#installation-steps)
3. [Database Setup](#database-setup)
4. [Backend Configuration](#backend-configuration)
5. [Frontend Setup](#frontend-setup)
6. [Running the Application](#running-the-application)
7. [Default User Credentials](#default-user-credentials)
8. [Troubleshooting](#troubleshooting)

---

## 🖥️ System Requirements

### Required Software:
- **XAMPP** (v8.1.17 or higher)
  - Apache Web Server
  - MySQL Database (v8.0 or higher)
  - PHP 8.1 or higher
- **Flutter SDK** (v3.0 or higher)
- **Dart SDK** (v3.0 or higher)
- **Git** (for version control)
- **Web Browser** (Chrome, Safari, Edge, or Firefox)

### Minimum Hardware:
- **RAM:** 4GB (8GB recommended)
- **Storage:** 2GB free space
- **Processor:** Intel Core i3 or equivalent

### Supported Platforms:
- ✅ Web (Chrome, Safari, Edge, Firefox)
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop
- ✅ Android (APK)
- ✅ iOS (requires macOS for building)

---

## 📥 Installation Steps

### Step 1: Install XAMPP

1. **Download XAMPP:**
   - Visit: https://www.apachefriends.org/
   - Download version 8.1.17 or higher for your OS

2. **Install XAMPP:**
   - macOS: Install to `/Applications/XAMPP/`
   - Windows: Install to `C:\xampp\`
   - Linux: Install to `/opt/lampp/`

3. **Start XAMPP Services:**
   ```bash
   # macOS/Linux
   sudo /Applications/XAMPP/xamppfiles/xampp start
   
   # Windows (Run as Administrator)
   C:\xampp\xampp-control.exe
   ```

4. **Verify Installation:**
   - Open browser: `http://localhost`
   - You should see the XAMPP dashboard

### Step 2: Install Flutter

1. **Download Flutter SDK:**
   - Visit: https://flutter.dev/docs/get-started/install
   - Download for your operating system

2. **Extract and Add to PATH:**
   ```bash
   # macOS/Linux - Add to ~/.zshrc or ~/.bashrc
   export PATH="$PATH:/path/to/flutter/bin"
   
   # Windows - Add to System Environment Variables
   C:\flutter\bin
   ```

3. **Verify Installation:**
   ```bash
   flutter doctor
   ```

4. **Enable Web Support:**
   ```bash
   flutter channel stable
   flutter upgrade
   flutter config --enable-web
   ```

---

## 🗄️ Database Setup

### Step 1: Create Database

1. **Access MySQL:**
   ```bash
   # macOS/Linux
   /Applications/XAMPP/xamppfiles/bin/mysql -u root
   
   # Windows
   C:\xampp\mysql\bin\mysql.exe -u root
   ```

2. **Create Database:**
   ```sql
   CREATE DATABASE tsaci_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE tsaci_db;
   ```

### Step 2: Import Database

Navigate to the database directory:
```bash
cd /Applications/XAMPP/xamppfiles/htdocs/tsaci/backend/database
```

**Option 1: Automated Import (Recommended)**

**For macOS/Linux:**
```bash
./IMPORT_DATABASE.sh
```

**For Windows:**
```cmd
IMPORT_DATABASE.bat
```

The script will automatically:
- ✅ Check MySQL connection
- ✅ Backup existing database (if any)
- ✅ Create fresh `tsaci_db` database
- ✅ Import all tables and data (11 tables, 116 records)
- ✅ Verify import success

**Option 2: Manual Import**

```bash
# Create database
mysql -u root -e "CREATE DATABASE IF NOT EXISTS tsaci_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import complete dump (includes all tables and data)
mysql -u root tsaci_db < tsaci_complete_dump.sql
```

This single file contains:
- All 11 table structures
- All 116 data records
- Proper foreign key relationships
- System configuration

### Step 3: Verify Database

```bash
mysql -u root tsaci_db -e "SHOW TABLES;"
```

You should see:
- ✅ customers
- ✅ expenses
- ✅ inventory
- ✅ production
- ✅ products
- ✅ sales
- ✅ suppliers
- ✅ system_config
- ✅ users
- ✅ production_batches
- ✅ batch_workers
- ✅ material_withdrawals

---

## ⚙️ Backend Configuration

### Step 1: Install PHP Dependencies

Navigate to the backend directory:
```bash
cd backend
composer install
```

### Step 2: Configure Database Connection

The default configuration should work, but verify in `backend/config/db.php`:

```php
private $host = "127.0.0.1";
private $db_name = "tsaci_db";
private $username = "root";
private $password = "";
private $port = "3306";
```

### Step 3: Set File Permissions (macOS/Linux)

```bash
chmod -R 755 backend/
chmod -R 777 backend/logs/
```

### Step 4: Configure Apache (if needed)

The application should be accessible at:
- **Base URL:** `http://localhost/tsaci/`
- **API URL:** `http://localhost/tsaci/backend/`

Verify `.htaccess` is enabled in Apache configuration.

---

## 🎨 Frontend Setup

### Step 1: Navigate to Project Root

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/tsaci
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This will install all required packages:
- dio (HTTP client)
- shared_preferences (local storage)
- google_fonts (Poppins font)
- fl_chart (charts and graphs)
- pdf & printing (PDF export)
- csv & path_provider (CSV export)
- image_picker (logo upload)
- intl (date formatting)
- connectivity_plus (network detection)

### Step 3: Verify API Connection

Check `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://localhost/tsaci/backend';
```

**Note:** If running on a physical device or different machine, update this URL to your server's IP address (e.g., `http://192.168.1.100/tsaci/backend`).

---

## 🚀 Running the Application

### Option 1: Run on Web (Recommended for Development)

```bash
flutter run -d chrome
```

Or specify a different browser:
```bash
flutter run -d web-server --web-port=8080
```

Then open: `http://localhost:8080`

### Option 2: Run on Desktop

**macOS:**
```bash
flutter run -d macos
```

**Windows:**
```bash
flutter run -d windows
```

**Linux:**
```bash
flutter run -d linux
```

### Option 3: Build for Production

**Web:**
```bash
flutter build web --release
# Output: build/web/
# Deploy to: htdocs/tsaci/web/
```

**Desktop:**
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

**Mobile:**
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS with Xcode)
flutter build ios --release
```

---

## 👥 Default User Credentials

### 1. **Administrator**
- **Email:** `admin@tsaci.com`
- **Password:** `admin123`
- **Access:** Full system access, user management, system configuration, all reports

### 2. **Production Manager**
- **Email:** `manager@tsaci.com`
- **Password:** `manager123`
- **Access:** Production planning, batch tracking, material usage, worker supervision, production reports

### 3. **Inventory Officer**
- **Email:** `inventory@tsaci.com`
- **Password:** `inventory123`
- **Access:** Inventory management, stock reports

### 4. **Quality Assurance Officer**
- **Email:** `qa@tsaci.com`
- **Password:** `qa123`
- **Access:** Quality control, QA reports

### 5. **Worker/Operator**
- **Email:** `worker@tsaci.com`
- **Password:** `worker123`
- **Access:** Production logs, task assignments

---

## 👷 Additional Team Members (Seeded Data)

### Production Managers (Supervisors):
| Name | Email | Password |
|------|-------|----------|
| John Martinez | john.martinez@tsaci.com | worker123 |
| Sarah Chen | sarah.chen@tsaci.com | worker123 |
| Michael Rodriguez | michael.rodriguez@tsaci.com | worker123 |

### Workers:
| Name | Email | Password |
|------|-------|----------|
| Maria Santos | maria.santos@tsaci.com | worker123 |
| Robert Lee | robert.lee@tsaci.com | worker123 |
| Jennifer Garcia | jennifer.garcia@tsaci.com | worker123 |
| David Wong | david.wong@tsaci.com | worker123 |
| Lisa Patel | lisa.patel@tsaci.com | worker123 |
| James Kim | james.kim@tsaci.com | worker123 |
| Anna Reyes | anna.reyes@tsaci.com | worker123 |
| Carlos Bautista | carlos.bautista@tsaci.com | worker123 |

---

## 🧪 Verifying Installation

### 1. Check Backend API

```bash
curl http://localhost/tsaci/backend/
```

Expected response:
```json
{
  "success": true,
  "message": "API is running",
  "data": {
    "name": "TSACI Plant Monitoring System API",
    "version": "1.0.0",
    "status": "running"
  }
}
```

### 2. Check Database Connection

```bash
mysql -u root tsaci_db -e "
SELECT 
  (SELECT COUNT(*) FROM users) as users,
  (SELECT COUNT(*) FROM products) as products,
  (SELECT COUNT(*) FROM production_batches) as batches,
  (SELECT COUNT(*) FROM material_withdrawals) as withdrawals;
"
```

Expected output:
```
+-------+----------+---------+-------------+
| users | products | batches | withdrawals |
+-------+----------+---------+-------------+
|    16 |        8 |       8 |          13 |
+-------+----------+---------+-------------+
```

### 3. Test Login

```bash
curl -X POST http://localhost/tsaci/backend/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tsaci.com","password":"admin123"}'
```

Should return a success response with a JWT token.

---

## 🔍 Troubleshooting

### Issue: "Connection refused" or "Cannot connect to database"

**Solution:**
1. Ensure MySQL is running:
   ```bash
   # macOS/Linux
   /Applications/XAMPP/xamppfiles/xampp status
   
   # Start if not running
   sudo /Applications/XAMPP/xamppfiles/xampp startmysql
   ```

2. Check MySQL credentials in `backend/config/db.php`

### Issue: "404 Not Found" for API endpoints

**Solution:**
1. Verify Apache is running
2. Check `.htaccess` in `backend/` directory
3. Enable `mod_rewrite` in Apache:
   ```bash
   # macOS
   sudo nano /Applications/XAMPP/xamppfiles/etc/httpd.conf
   # Uncomment: LoadModule rewrite_module modules/mod_rewrite.so
   ```

### Issue: "CORS Policy Error"

**Solution:**
The application includes CORS configuration. If issues persist:
1. Check `backend/config/cors.php`
2. Restart Apache after changes

### Issue: Flutter dependencies not installing

**Solution:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Issue: "No data showing in app"

**Solution:**
1. Verify backend is running: `http://localhost/tsaci/backend/`
2. Check API URL in Flutter: `lib/core/constants/api_constants.dart`
3. Re-seed database:
   ```bash
   mysql -u root tsaci_db < backend/database/seed_data.sql
   ```

### Issue: Login fails with 401 error

**Solution:**
1. Verify user exists in database:
   ```bash
   mysql -u root tsaci_db -e "SELECT email, role FROM users;"
   ```
2. Ensure password hashes are correct (use `update_roles.sql`)
3. Check JWT secret key in `backend/middleware/jwt_auth.php`

---

## 📊 Seeded Data Overview

After installation, the system includes:

### Users (16 total):
- 1 Admin
- 4 Production Managers
- 9 Workers
- 1 Inventory Officer
- 1 QA Officer

### Production Data:
- 8 Products (various categories)
- 8 Inventory items with stock levels
- 8 Production batches (2 completed, 3 ongoing, 3 planned)
- 16 Batch-worker assignments
- 13 Material withdrawal requests (5 pending, 5 approved, 3 rejected)

### Business Data:
- 10 Production logs with efficiency metrics
- 12 Sales transactions (₱301,000 revenue)
- 10 Expense records (₱210,500 total)
- 5 Customers
- 4 Suppliers

### Financial Metrics:
- Total Revenue: ₱301,000
- Total Expenses: ₱210,500
- Net Income: ₱90,500
- Average Production Efficiency: 94.1%

---

## 🎯 First Login Steps

### 1. Start the Application

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/tsaci
flutter run -d chrome
```

### 2. Login as Administrator

- **URL:** `http://localhost:[PORT]`
- **Email:** `admin@tsaci.com`
- **Password:** `admin123`

### 3. Explore Features

**Admin Dashboard:**
- View system-wide KPIs
- Manage users, products, inventory
- Configure system settings
- Generate reports

**Production Manager Dashboard:**
- Login: `manager@tsaci.com` / `manager123`
- Production planning (8 batches)
- Batch tracking (multi-stage workflow)
- Material usage (13 requests)
- Worker supervision
- Production reports

---

## 🔐 Security Notes

### Production Deployment:

1. **Change Default Passwords:**
   ```sql
   UPDATE users SET password_hash = '$2y$10$YOUR_NEW_HASH' WHERE email = 'admin@tsaci.com';
   ```

2. **Update JWT Secret Key:**
   Edit `backend/middleware/jwt_auth.php`:
   ```php
   private static $secret_key = "YOUR_SECURE_SECRET_KEY_HERE";
   ```

3. **Configure CORS:**
   Edit `backend/config/cors.php` to allow only your domain:
   ```php
   header('Access-Control-Allow-Origin: https://yourdomain.com');
   ```

4. **Enable HTTPS:**
   - Configure SSL certificate in Apache
   - Update Flutter API URL to use `https://`

5. **Set Strong Database Password:**
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_password';
   ```

---

## 📁 Project Structure

```
tsaci/
├── lib/                          # Flutter application code
│   ├── core/                     # Core utilities, theme, widgets
│   ├── models/                   # Data models
│   ├── screens/                  # UI screens
│   │   ├── admin/               # Admin module
│   │   ├── production_manager/  # Production manager module
│   │   ├── manager/             # Reports module
│   │   └── auth/                # Authentication
│   ├── services/                # API services
│   └── utils/                   # Utility functions
├── backend/                     # PHP backend
│   ├── api/                     # Business logic controllers
│   ├── config/                  # Configuration files
│   ├── controllers/             # Request handlers
│   ├── database/                # SQL scripts
│   ├── helpers/                 # Helper functions
│   ├── middleware/              # JWT authentication
│   ├── models/                  # Data models
│   └── index.php               # API entry point
├── pubspec.yaml                # Flutter dependencies
└── INSTALL.md                  # This file
```

---

## 🔄 Database Maintenance

### Re-seed All Data:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/tsaci/backend/database

# Clear and re-import everything
mysql -u root -e "DROP DATABASE IF EXISTS tsaci_db; CREATE DATABASE tsaci_db;"
mysql -u root tsaci_db < schema.sql
mysql -u root tsaci_db < system_config_table.sql
mysql -u root tsaci_db < update_roles.sql
mysql -u root tsaci_db < production_batches_table.sql
mysql -u root tsaci_db < seed_data.sql
mysql -u root tsaci_db < seed_supervisors_workers.sql
mysql -u root tsaci_db < seed_material_withdrawals.sql
```

### Backup Database:

```bash
mysqldump -u root tsaci_db > backup_$(date +%Y%m%d).sql
```

### Restore Database:

```bash
mysql -u root tsaci_db < backup_20251015.sql
```

---

## 📱 Mobile App Deployment

### Android APK:

1. **Build APK:**
   ```bash
   flutter build apk --release
   ```

2. **Install on Device:**
   ```bash
   flutter install
   ```

3. **Output Location:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### iOS App (requires macOS):

1. **Build iOS:**
   ```bash
   flutter build ios --release
   ```

2. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Configure signing and deploy via Xcode**

---

## 🌐 Web Deployment

### Option 1: Deploy to XAMPP htdocs

```bash
flutter build web --release
cp -r build/web/* /Applications/XAMPP/xamppfiles/htdocs/tsaci/web/
```

Access at: `http://localhost/tsaci/web/`

### Option 2: Deploy to Production Server

1. **Build for web:**
   ```bash
   flutter build web --release --base-href /tsaci/
   ```

2. **Upload to server:**
   - Upload `build/web/*` to your web server
   - Upload `backend/*` to your PHP server
   - Configure database on production

3. **Update API URL:**
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'https://yourdomain.com/api';
   ```

---

## 📧 Support

For issues or questions:
- Review logs: `backend/logs/tsaci.log`
- Check Flutter logs: Run with `flutter run -v`
- Database errors: Check MySQL error logs

---

## ✅ Installation Checklist

- [ ] XAMPP installed and running (Apache + MySQL)
- [ ] Flutter SDK installed and configured
- [ ] Database `tsaci_db` created
- [ ] All database tables imported (11 tables)
- [ ] All seed data imported (16 users, 8 products, 8 batches, etc.)
- [ ] PHP dependencies installed (composer)
- [ ] Flutter dependencies installed (pub get)
- [ ] Backend API accessible at `http://localhost/tsaci/backend/`
- [ ] Frontend running successfully
- [ ] Can login with `admin@tsaci.com` / `admin123`
- [ ] Dashboard loads with real data

---

## 🎉 Installation Complete!

Your TSACI Plant Monitoring System is now ready to use!

**Quick Start:**
1. Login as Admin: `admin@tsaci.com` / `admin123`
2. Explore the dashboard with real production data
3. Try Production Manager: `manager@tsaci.com` / `manager123`
4. Create new production batches, approve material requests, track progress!

**Key Features Available:**
- ✅ User management (16 users)
- ✅ Product management (8 products)
- ✅ Inventory management (real-time stock)
- ✅ Production planning (8 batches)
- ✅ Batch tracking (multi-stage workflow)
- ✅ Material usage (13 requests)
- ✅ Worker supervision
- ✅ Comprehensive reports (Production, Sales, Expense, Inventory, Performance)
- ✅ PDF/CSV export functionality
- ✅ System configuration (white labeling, token settings, logo upload)

Enjoy using TSACI! 🚀


# TSACI Database Files

## 📁 Files Overview

### Main Database File:
- **`tsaci_complete_dump.sql`** - Complete database export with all tables and data (RECOMMENDED)

### Import Scripts:
- **`IMPORT_DATABASE.sh`** - Automated import script for macOS/Linux
- **`IMPORT_DATABASE.bat`** - Automated import script for Windows

---

## 🚀 Quick Start (Recommended)

### For macOS/Linux:
```bash
cd backend/database
./IMPORT_DATABASE.sh
```

### For Windows:
```cmd
cd backend\database
IMPORT_DATABASE.bat
```

The scripts will:
1. ✅ Check MySQL connection
2. ✅ Backup existing database (if any)
3. ✅ Create fresh `tsaci_db` database
4. ✅ Import all tables and data
5. ✅ Verify import success
6. ✅ Display record counts

---

## 📊 Manual Import (Alternative)

If you prefer manual control:

```bash
# 1. Create database
mysql -u root -e "CREATE DATABASE IF NOT EXISTS tsaci_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Import complete dump
mysql -u root tsaci_db < tsaci_complete_dump.sql

# 3. Verify import
mysql -u root tsaci_db -e "SHOW TABLES; SELECT COUNT(*) as users FROM users;"
```

---

## 📋 Database Contents

### Tables (11 total):
1. **users** - User accounts and authentication
2. **products** - Product catalog
3. **inventory** - Stock levels and locations
4. **production_batches** - Production planning batches
5. **batch_workers** - Team assignments for batches
6. **material_withdrawals** - Material request management
7. **production** - Production logs and history
8. **sales** - Sales transactions
9. **expenses** - Expense tracking
10. **customers** - Customer information
11. **suppliers** - Supplier information
12. **system_config** - System configuration settings

### Seeded Data:
- **16 Users** (5 main roles + 11 team members)
- **8 Products** (various categories)
- **8 Inventory items** (with stock levels)
- **8 Production batches** (planned, ongoing, completed)
- **16 Batch-worker assignments**
- **13 Material withdrawals** (pending, approved, rejected)
- **10 Production logs** (historical data)
- **12 Sales transactions** (₱301,000 revenue)
- **10 Expense records** (₱210,500 total)
- **5 Customers**
- **4 Suppliers**

---

## 👥 Default User Credentials

After import, you can login with:

| Role | Email | Password | Access |
|------|-------|----------|---------|
| **Admin** | admin@tsaci.com | admin123 | Full system access |
| **Production Manager** | manager@tsaci.com | manager123 | Production operations |
| **Inventory Officer** | inventory@tsaci.com | inventory123 | Inventory management |
| **QA Officer** | qa@tsaci.com | qa123 | Quality assurance |
| **Worker** | worker@tsaci.com | worker123 | Production tasks |

**Additional team members:** 
- 3 Production Managers (john.martinez, sarah.chen, michael.rodriguez)
- 8 Workers (maria.santos, robert.lee, jennifer.garcia, david.wong, lisa.patel, james.kim, anna.reyes, carlos.bautista)
- All additional users use password: `worker123`

---

## 🔄 Maintenance

### Export Current Database:
```bash
mysqldump -u root tsaci_db --no-tablespaces > tsaci_backup_$(date +%Y%m%d).sql
```

### Reset to Original State:
```bash
# macOS/Linux
./IMPORT_DATABASE.sh

# Windows
IMPORT_DATABASE.bat
```

### Clear All Data (Keep Structure):
```bash
mysql -u root tsaci_db -e "
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE batch_workers;
TRUNCATE TABLE material_withdrawals;
TRUNCATE TABLE production_batches;
TRUNCATE TABLE production;
TRUNCATE TABLE sales;
TRUNCATE TABLE expenses;
TRUNCATE TABLE inventory;
DELETE FROM users WHERE user_id > 5;
SET FOREIGN_KEY_CHECKS=1;
"
```

---

## 🧪 Verification Queries

### Check All Table Counts:
```sql
SELECT 
  'users' as table_name, COUNT(*) as count FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'production_batches', COUNT(*) FROM production_batches
UNION ALL SELECT 'batch_workers', COUNT(*) FROM batch_workers
UNION ALL SELECT 'material_withdrawals', COUNT(*) FROM material_withdrawals
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'expenses', COUNT(*) FROM expenses
UNION ALL SELECT 'production', COUNT(*) FROM production;
```

Expected result:
```
users                   16
products                 8
inventory                8
production_batches       8
batch_workers           16
material_withdrawals    13
customers                5
sales                   12
expenses                10
production              10
```

### Check Foreign Key Relationships:
```sql
-- Verify batch worker assignments
SELECT 
  pb.batch_number,
  COUNT(*) as team_size,
  GROUP_CONCAT(u.name SEPARATOR ', ') as team
FROM production_batches pb
JOIN batch_workers bw ON pb.batch_id = bw.batch_id
JOIN users u ON bw.user_id = u.user_id
GROUP BY pb.batch_id
LIMIT 5;

-- Verify material withdrawals linked to batches
SELECT 
  COUNT(*) as total_withdrawals,
  COUNT(DISTINCT batch_id) as linked_batches
FROM material_withdrawals
WHERE batch_id IS NOT NULL;
```

---

## ⚠️ Important Notes

1. **Foreign Key Constraints:**
   - All tables use proper foreign keys
   - Cascade deletes are configured where appropriate
   - Import order matters (handled by import scripts)

2. **Character Encoding:**
   - Database uses `utf8mb4` for full Unicode support
   - Handles emoji and special characters

3. **Timestamps:**
   - All tables have `created_at` and `updated_at`
   - Auto-update on modifications

4. **Data Integrity:**
   - All seeded data is properly linked
   - No orphaned records
   - All foreign keys validated

---

## 📧 Support

If import fails:
1. Check MySQL is running: `sudo /Applications/XAMPP/xamppfiles/xampp status`
2. Verify MySQL root access: `mysql -u root -e "SELECT 1;"`
3. Check error logs: `tail -f /Applications/XAMPP/xamppfiles/logs/mysql_error.log`

---

## ✅ Database Import Checklist

- [ ] MySQL service is running
- [ ] Root user has access (no password required for XAMPP default)
- [ ] Old `tsaci_db` backed up (if exists)
- [ ] Import script executed successfully
- [ ] All 11 tables created
- [ ] All data imported (verify counts match expected)
- [ ] Can login with default credentials
- [ ] Application loads data correctly

---

**Database Version:** 1.0.0  
**Last Updated:** October 15, 2025  
**Total Records:** 116 across all tables


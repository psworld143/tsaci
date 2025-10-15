# Quick Database Import Guide

## 🎯 Single Command Import

### macOS/Linux:
```bash
cd backend/database
./IMPORT_DATABASE.sh
```

### Windows:
```cmd
cd backend\database
IMPORT_DATABASE.bat
```

---

## 📦 What Gets Imported:

✅ **11 Database Tables:**
- users, products, inventory
- production_batches, batch_workers
- material_withdrawals
- production, sales, expenses
- customers, suppliers
- system_config

✅ **116 Total Records:**
- 16 Users (all roles)
- 8 Products (all categories)
- 8 Inventory items (with stock)
- 8 Production batches (multi-stage)
- 16 Team assignments
- 13 Material withdrawal requests
- 12 Sales transactions
- 10 Expenses
- 10 Production logs
- 5 Customers
- 4 Suppliers

✅ **Complete System State:**
- All data is interconnected
- Foreign keys validated
- No orphaned records
- Ready to use immediately

---

## 🔐 Default Login Credentials

**Main Accounts:**
```
Admin:               admin@tsaci.com / admin123
Production Manager:  manager@tsaci.com / manager123
Inventory Officer:   inventory@tsaci.com / inventory123
QA Officer:          qa@tsaci.com / qa123
Worker:              worker@tsaci.com / worker123
```

**Additional Team Members:**
```
All use password: worker123

Supervisors:
- john.martinez@tsaci.com
- sarah.chen@tsaci.com
- michael.rodriguez@tsaci.com

Workers:
- maria.santos@tsaci.com
- robert.lee@tsaci.com
- jennifer.garcia@tsaci.com
- david.wong@tsaci.com
- lisa.patel@tsaci.com
- james.kim@tsaci.com
- anna.reyes@tsaci.com
- carlos.bautista@tsaci.com
```

---

## ⚡ Import Time

- **Small dataset:** ~2 seconds
- **No configuration needed**
- **Automatic verification**

---

## 🔄 Re-import Instructions

If you need to reset the database:

```bash
# Run the import script again - it will:
# 1. Backup your current data
# 2. Drop and recreate database
# 3. Import fresh data
# 4. Verify success

./IMPORT_DATABASE.sh  # macOS/Linux
# or
IMPORT_DATABASE.bat   # Windows
```

---

## ✅ Verification

After import completes, you should see:

```
table_name              count
users                      16
products                    8
inventory                   8
production_batches          8
batch_workers              16
material_withdrawals       13
customers                   5
sales                      12
expenses                   10
production                 10
```

**If counts don't match, re-run the import script.**

---

## 🎉 That's It!

Your database is ready. Start the Flutter app and login!


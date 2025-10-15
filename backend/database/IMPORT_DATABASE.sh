#!/bin/bash
#
# TSACI Database Import Script
# This script will create and populate the tsaci_db database
#

echo "========================================="
echo "TSACI Database Import Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if MySQL is accessible
echo -n "Checking MySQL connection... "
if ! mysql -u root -e "SELECT 1;" &> /dev/null; then
    echo -e "${RED}FAILED${NC}"
    echo "Error: Cannot connect to MySQL."
    echo "Please ensure MySQL is running and accessible with root user."
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Backup existing database if it exists
echo -n "Checking for existing database... "
if mysql -u root -e "USE tsaci_db;" &> /dev/null; then
    echo -e "${YELLOW}EXISTS${NC}"
    echo -n "Creating backup... "
    mysqldump -u root tsaci_db > "tsaci_backup_$(date +%Y%m%d_%H%M%S).sql" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAILED${NC}"
    fi
else
    echo -e "${GREEN}NOT FOUND${NC}"
fi

# Drop and recreate database
echo -n "Creating fresh database... "
mysql -u root -e "DROP DATABASE IF EXISTS tsaci_db; CREATE DATABASE tsaci_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

# Import complete dump
echo -n "Importing database structure and data... "
mysql -u root tsaci_db < tsaci_complete_dump.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

# Verify import
echo ""
echo "Verifying import..."
echo "===================="

# Count records in each table
mysql -u root tsaci_db -e "
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
"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Database import completed successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "You can now start the application."
echo ""
echo "Default login credentials:"
echo "  Admin: admin@tsaci.com / admin123"
echo "  Production Manager: manager@tsaci.com / manager123"
echo ""


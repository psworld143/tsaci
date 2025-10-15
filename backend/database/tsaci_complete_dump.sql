-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for osx10.10 (x86_64)
--
-- Host: localhost    Database: tsaci_db
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `batch_workers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_workers` (
  `batch_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role_type` enum('supervisor','worker') NOT NULL DEFAULT 'worker',
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`batch_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `batch_workers_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `production_batches` (`batch_id`) ON DELETE CASCADE,
  CONSTRAINT `batch_workers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_workers`
--

LOCK TABLES `batch_workers` WRITE;
/*!40000 ALTER TABLE `batch_workers` DISABLE KEYS */;
INSERT INTO `batch_workers` (`batch_id`, `user_id`, `role_type`, `assigned_at`) VALUES (1,2,'supervisor','2025-10-15 09:45:01'),(1,5,'worker','2025-10-15 09:45:01'),(2,2,'supervisor','2025-10-15 09:45:01'),(2,5,'worker','2025-10-15 09:45:01'),(3,2,'supervisor','2025-10-15 09:45:01'),(3,5,'worker','2025-10-15 09:45:01'),(4,2,'supervisor','2025-10-15 09:45:01'),(4,5,'worker','2025-10-15 09:45:01'),(5,2,'supervisor','2025-10-15 09:45:01'),(5,5,'worker','2025-10-15 09:45:01'),(6,2,'supervisor','2025-10-15 09:45:01'),(6,5,'worker','2025-10-15 09:45:01'),(7,2,'supervisor','2025-10-15 09:45:01'),(7,5,'worker','2025-10-15 09:45:01'),(8,2,'supervisor','2025-10-15 09:45:01'),(8,5,'worker','2025-10-15 09:45:01');
/*!40000 ALTER TABLE `batch_workers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` (`customer_id`, `name`, `contact`, `address`, `created_at`, `updated_at`) VALUES (1,'ABC Trading Corp','+63-917-123-4567','123 Business St, Manila','2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,'XYZ Wholesale Inc','+63-918-234-5678','456 Commerce Ave, Quezon City','2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,'Global Exports Ltd','+63-919-345-6789','789 Export Road, Makati','2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,'Local Distributors','+63-920-456-7890','321 Market St, Pasig','2025-10-15 09:42:13','2025-10-15 09:42:13'),(5,'Premium Buyers Co','+63-921-567-8901','654 Premium Plaza, BGC','2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `expense_id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `date` date NOT NULL,
  `description` text DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`expense_id`),
  KEY `idx_expenses_date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` (`expense_id`, `category`, `amount`, `date`, `description`, `department`, `created_at`, `updated_at`) VALUES (1,'Raw Materials',45000.00,'2025-10-14','Coconut purchase - 5 tons','Production','2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,'Utilities',12500.00,'2025-10-13','Electricity bill - December','Operations','2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,'Maintenance',8500.00,'2025-10-12','Equipment servicing','Production','2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,'Labor',35000.00,'2025-10-10','Worker salaries - Week 1','HR','2025-10-15 09:42:13','2025-10-15 09:42:13'),(5,'Transportation',6500.00,'2025-10-08','Delivery trucks fuel','Logistics','2025-10-15 09:42:13','2025-10-15 09:42:13'),(6,'Raw Materials',38000.00,'2025-10-05','Coconut purchase - 4 tons','Production','2025-10-15 09:42:13','2025-10-15 09:42:13'),(7,'Supplies',3200.00,'2025-10-03','Packaging materials','Production','2025-10-15 09:42:13','2025-10-15 09:42:13'),(8,'Utilities',11800.00,'2025-09-30','Water bill','Operations','2025-10-15 09:42:13','2025-10-15 09:42:13'),(9,'Maintenance',15000.00,'2025-09-27','Machine parts replacement','Production','2025-10-15 09:42:13','2025-10-15 09:42:13'),(10,'Labor',35000.00,'2025-09-25','Worker salaries - Week 2','HR','2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory` (
  `inventory_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 0.00,
  `location` varchar(100) DEFAULT NULL,
  `minimum_threshold` decimal(10,2) DEFAULT 10.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `unique_product_location` (`product_id`,`location`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` (`inventory_id`, `product_id`, `quantity`, `location`, `minimum_threshold`, `created_at`, `updated_at`) VALUES (1,1,5000.00,'Warehouse A - Section 1',500.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,2,3200.00,'Warehouse A - Section 2',400.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,3,4500.00,'Warehouse B - Tank 1',600.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,4,2800.00,'Warehouse B - Tank 2',300.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(5,5,6000.00,'Warehouse C - Bin 1',800.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(6,6,1500.00,'Warehouse C - Bin 2',200.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(7,7,3500.00,'Warehouse D - Storage 1',500.00,'2025-10-15 09:42:13','2025-10-15 09:42:13'),(8,8,800.00,'Warehouse D - Storage 2',150.00,'2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_withdrawals`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_withdrawals` (
  `withdrawal_id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_id` int(11) NOT NULL,
  `requested_quantity` decimal(10,2) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `purpose` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  PRIMARY KEY (`withdrawal_id`),
  KEY `inventory_id` (`inventory_id`),
  KEY `requested_by` (`requested_by`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_status` (`status`),
  KEY `idx_batch` (`batch_id`),
  CONSTRAINT `material_withdrawals_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`inventory_id`) ON DELETE CASCADE,
  CONSTRAINT `material_withdrawals_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `material_withdrawals_ibfk_3` FOREIGN KEY (`batch_id`) REFERENCES `production_batches` (`batch_id`) ON DELETE SET NULL,
  CONSTRAINT `material_withdrawals_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_withdrawals`
--

LOCK TABLES `material_withdrawals` WRITE;
/*!40000 ALTER TABLE `material_withdrawals` DISABLE KEYS */;
INSERT INTO `material_withdrawals` (`withdrawal_id`, `inventory_id`, `requested_quantity`, `requested_by`, `batch_id`, `purpose`, `status`, `requested_at`, `approved_by`, `approved_at`, `rejection_reason`) VALUES (1,1,800.00,5,1,'Raw materials for Batch PB-2025-001','approved','2025-10-10 10:15:53',2,'2025-10-10 10:15:53',NULL),(2,3,1200.00,5,2,'Raw materials for Batch PB-2025-002','approved','2025-10-11 10:15:53',2,'2025-10-11 10:15:53',NULL),(3,2,650.00,9,3,'Production materials for Batch PB-2025-003','approved','2025-10-13 10:15:53',2,'2025-10-13 10:15:53',NULL),(4,4,950.00,10,4,'Materials for Batch PB-2025-004','approved','2025-10-14 10:15:53',6,'2025-10-14 10:15:53',NULL),(5,7,1500.00,11,5,'Carbon materials for Batch PB-2025-005','approved','2025-10-15 10:15:53',7,'2025-10-15 10:15:53',NULL),(6,5,1400.00,12,6,'Materials needed for upcoming Batch PB-2025-006','pending','2025-10-15 10:15:53',NULL,NULL,NULL),(7,1,750.00,13,7,'Raw materials for Batch PB-2025-007','pending','2025-10-15 10:15:53',NULL,NULL,NULL),(8,2,200.00,14,NULL,'Quality testing samples','pending','2025-10-15 10:15:53',NULL,NULL,NULL),(9,4,300.00,15,NULL,'Maintenance and equipment cleaning','pending','2025-10-15 10:15:53',NULL,NULL,NULL),(10,6,450.00,16,NULL,'Research and development','pending','2025-10-15 10:15:53',NULL,NULL,NULL),(11,1,3000.00,9,NULL,'Large quantity request','rejected','2025-10-12 10:15:53',2,'2025-10-12 10:15:53','Excessive quantity - exceeds daily allocation'),(12,5,7000.00,10,NULL,'Bulk order preparation','rejected','2025-10-13 10:15:53',6,'2025-10-13 10:15:53','Insufficient stock available'),(13,8,1000.00,11,NULL,'Special production run','rejected','2025-10-14 10:15:53',7,'2025-10-14 10:15:53','No approved production batch');
/*!40000 ALTER TABLE `material_withdrawals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `production` (
  `production_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `supervisor_id` int(11) NOT NULL,
  `input_qty` decimal(10,2) NOT NULL,
  `output_qty` decimal(10,2) NOT NULL,
  `date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`production_id`),
  KEY `product_id` (`product_id`),
  KEY `supervisor_id` (`supervisor_id`),
  KEY `idx_production_date` (`date`),
  CONSTRAINT `production_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `production_ibfk_2` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production`
--

LOCK TABLES `production` WRITE;
/*!40000 ALTER TABLE `production` DISABLE KEYS */;
INSERT INTO `production` (`production_id`, `product_id`, `supervisor_id`, `input_qty`, `output_qty`, `date`, `notes`, `created_at`, `updated_at`) VALUES (1,1,5,1200.00,1080.00,'2025-10-14','Smooth processing, good quality','2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,2,5,800.00,760.00,'2025-10-14','Standard batch, no issues','2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,3,5,1500.00,1425.00,'2025-10-13','High efficiency run','2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,4,5,900.00,855.00,'2025-10-13','Premium grade output','2025-10-15 09:42:13','2025-10-15 09:42:13'),(5,1,5,1100.00,990.00,'2025-10-12','Minor equipment delay','2025-10-15 09:42:13','2025-10-15 09:42:13'),(6,5,5,2000.00,1900.00,'2025-10-12','Large batch completed','2025-10-15 09:42:13','2025-10-15 09:42:13'),(7,7,5,1300.00,1235.00,'2025-10-11','Excellent activation','2025-10-15 09:42:13','2025-10-15 09:42:13'),(8,3,5,1400.00,1330.00,'2025-10-10','Good extraction rate','2025-10-15 09:42:13','2025-10-15 09:42:13'),(9,2,5,750.00,720.00,'2025-10-09','Quality maintained','2025-10-15 09:42:13','2025-10-15 09:42:13'),(10,8,5,600.00,570.00,'2025-10-08','Fine powder achieved','2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `production` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_batches`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `production_batches` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_number` varchar(50) NOT NULL,
  `product_id` int(11) NOT NULL,
  `target_quantity` decimal(10,2) NOT NULL,
  `scheduled_date` date NOT NULL,
  `status` enum('planned','ongoing','on_hold','completed','cancelled') NOT NULL DEFAULT 'planned',
  `current_stage` enum('mixing','packing','qa','dispatch') NOT NULL DEFAULT 'mixing',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `batch_number` (`batch_number`),
  KEY `product_id` (`product_id`),
  KEY `idx_status` (`status`),
  KEY `idx_scheduled_date` (`scheduled_date`),
  CONSTRAINT `production_batches_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_batches`
--

LOCK TABLES `production_batches` WRITE;
/*!40000 ALTER TABLE `production_batches` DISABLE KEYS */;
INSERT INTO `production_batches` (`batch_id`, `batch_number`, `product_id`, `target_quantity`, `scheduled_date`, `status`, `current_stage`, `notes`, `created_at`, `updated_at`) VALUES (1,'PB-2025-001',1,1000.00,'2025-10-10','completed','dispatch','Successfully completed ahead of schedule','2025-10-15 09:45:01','2025-10-15 09:45:01'),(2,'PB-2025-002',3,1500.00,'2025-10-11','completed','dispatch','High quality output achieved','2025-10-15 09:45:01','2025-10-15 09:45:01'),(3,'PB-2025-003',2,800.00,'2025-10-13','ongoing','packing','Progressing as planned','2025-10-15 09:45:01','2025-10-15 09:45:01'),(4,'PB-2025-004',4,1200.00,'2025-10-14','ongoing','qa','Quality check in progress','2025-10-15 09:45:01','2025-10-15 09:45:01'),(5,'PB-2025-005',7,2000.00,'2025-10-15','ongoing','mixing','Started this morning','2025-10-15 09:45:01','2025-10-15 09:45:01'),(6,'PB-2025-006',5,1800.00,'2025-10-16','planned','mixing','Scheduled for tomorrow','2025-10-15 09:45:01','2025-10-15 09:45:01'),(7,'PB-2025-007',1,900.00,'2025-10-18','planned','mixing','Materials ready','2025-10-15 09:45:01','2025-10-15 09:45:01'),(8,'PB-2025-008',8,600.00,'2025-10-20','planned','mixing','Customer order #CO-2025-045','2025-10-15 09:45:01','2025-10-15 09:45:01');
/*!40000 ALTER TABLE `production_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` (`product_id`, `name`, `category`, `price`, `unit`, `created_at`, `updated_at`) VALUES (1,'Coconut Water Concentrate','Beverages',150.00,'liter','2025-10-14 07:30:16','2025-10-14 07:30:16'),(2,'Coconut Cream','Dairy',200.00,'liter','2025-10-14 07:30:16','2025-10-14 07:30:16'),(3,'Crude Coconut Oil','Oil',180.00,'liter','2025-10-14 07:30:16','2025-10-14 07:30:16'),(4,'RBD Coconut Oil','Oil',250.00,'liter','2025-10-14 07:30:16','2025-10-14 07:30:16'),(5,'Coconut Husk Chips','Horticulture',50.00,'kg','2025-10-14 07:30:16','2025-10-14 07:30:16'),(6,'Coconut Pit','Horticulture',30.00,'kg','2025-10-14 07:30:16','2025-10-14 07:30:16'),(7,'Activated Carbon Granulated','Carbon',300.00,'kg','2025-10-14 07:30:16','2025-10-14 07:30:16'),(8,'Activated Carbon Charcoal Dust','Carbon',250.00,'kg','2025-10-14 07:30:16','2025-10-14 07:30:16');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sales` (
  `sale_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','completed','cancelled') DEFAULT 'pending',
  `date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`sale_id`),
  KEY `customer_id` (`customer_id`),
  KEY `product_id` (`product_id`),
  KEY `idx_sales_date` (`date`),
  CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE,
  CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` (`sale_id`, `customer_id`, `product_id`, `quantity`, `unit_price`, `total_amount`, `status`, `date`, `created_at`, `updated_at`) VALUES (1,1,1,500.00,45.00,22500.00,'completed','2025-10-13','2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,2,2,300.00,55.00,16500.00,'completed','2025-10-12','2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,3,3,800.00,65.00,52000.00,'completed','2025-10-10','2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,1,4,400.00,75.00,30000.00,'completed','2025-10-08','2025-10-15 09:42:13','2025-10-15 09:42:13'),(5,4,7,600.00,85.00,51000.00,'completed','2025-10-05','2025-10-15 09:42:13','2025-10-15 09:42:13'),(6,5,1,450.00,45.00,20250.00,'completed','2025-10-03','2025-10-15 09:42:13','2025-10-15 09:42:13'),(7,2,5,1000.00,25.00,25000.00,'completed','2025-09-30','2025-10-15 09:42:13','2025-10-15 09:42:13'),(8,3,3,700.00,65.00,45500.00,'completed','2025-09-27','2025-10-15 09:42:13','2025-10-15 09:42:13'),(9,4,8,200.00,95.00,19000.00,'completed','2025-09-25','2025-10-15 09:42:13','2025-10-15 09:42:13'),(10,1,2,350.00,55.00,19250.00,'completed','2025-09-23','2025-10-15 09:42:13','2025-10-15 09:42:13'),(11,5,4,300.00,75.00,22500.00,'pending','2025-10-15','2025-10-15 09:42:13','2025-10-15 09:42:13'),(12,2,7,400.00,85.00,34000.00,'pending','2025-10-15','2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` (`supplier_id`, `name`, `contact`, `address`, `created_at`, `updated_at`) VALUES (1,'Coconut Farms Alliance','+63-922-111-2222','Coconut Valley, Laguna','2025-10-15 09:42:13','2025-10-15 09:42:13'),(2,'Raw Materials Depot','+63-923-222-3333','Industrial Park, Cavite','2025-10-15 09:42:13','2025-10-15 09:42:13'),(3,'Pacific Trading','+63-924-333-4444','Port Area, Manila','2025-10-15 09:42:13','2025-10-15 09:42:13'),(4,'Agri-Supply Hub','+63-925-444-5555','Farm Road, Batangas','2025-10-15 09:42:13','2025-10-15 09:42:13');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_config` (
  `config_id` int(11) NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) NOT NULL,
  `config_value` text NOT NULL,
  `config_type` enum('text','json','image') DEFAULT 'text',
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
INSERT INTO `system_config` (`config_id`, `config_key`, `config_value`, `config_type`, `description`, `created_at`, `updated_at`) VALUES (1,'system_name','TSACI Plant Monitoring System','text','System display name','2025-10-14 11:07:44','2025-10-14 11:07:44'),(2,'system_logo','','image','System logo URL or base64','2025-10-14 11:07:44','2025-10-14 11:07:44'),(3,'theme_color','#2D6A4F','text','Primary theme color','2025-10-14 11:07:44','2025-10-14 11:07:44'),(4,'production_stages','[\"Harvesting\", \"Processing\", \"Quality Check\", \"Packaging\", \"Storage\"]','json','Production stages','2025-10-14 11:07:44','2025-10-14 11:07:44'),(5,'product_categories','[\"Beverages\", \"Dairy\", \"Oil\", \"Horticulture\", \"Carbon\"]','json','Product categories','2025-10-14 11:07:44','2025-10-14 11:07:44'),(6,'units_of_measurement','[\"kg\", \"liter\", \"pcs\", \"box\", \"bag\", \"ton\"]','json','Available units','2025-10-14 11:07:44','2025-10-14 11:07:44');
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','production_manager','inventory_officer','qa_officer','worker') NOT NULL DEFAULT 'worker',
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`, `name`, `email`, `role`, `password_hash`, `created_at`, `updated_at`) VALUES (1,'System Administrator','admin@tsaci.com','admin','$2y$10$MyoM8xvFVcWbjtfwNZL.IedSXjOcbS5o8ST3qkvr9HQZTFrUegmv2','2025-10-15 08:39:07','2025-10-15 08:58:31'),(2,'Production Manager','manager@tsaci.com','production_manager','$2y$10$RzCFMuyObqF5SdYxM3K58ezpZDU8nslcFifB2Xxp5r2DgF4fgzj.m','2025-10-15 08:39:07','2025-10-15 08:56:19'),(3,'Inventory Officer','inventory@tsaci.com','inventory_officer','$2y$10$NhQamiT0EBYJukzEdRpYnOZYuHtbBVPTmam.mqykQxZqXHb5ro83e','2025-10-15 08:39:07','2025-10-15 08:56:23'),(4,'QA Officer','qa@tsaci.com','qa_officer','$2y$10$T6NSXhKFk8pRTROGMjGgluRAqk8WlOb1EJs.xj.C2YvQBYEInBK6S','2025-10-15 08:39:07','2025-10-15 08:56:24'),(5,'Worker','worker@tsaci.com','worker','$2y$10$vpBLAYVCRc2qwvm5/pbPCuFJr82MeGZWLIAZpMONjdfH5Gg67oop6','2025-10-15 08:39:07','2025-10-15 08:56:25'),(6,'John Martinez','john.martinez@tsaci.com','production_manager','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(7,'Sarah Chen','sarah.chen@tsaci.com','production_manager','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(8,'Michael Rodriguez','michael.rodriguez@tsaci.com','production_manager','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(9,'Maria Santos','maria.santos@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(10,'Robert Lee','robert.lee@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(11,'Jennifer Garcia','jennifer.garcia@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(12,'David Wong','david.wong@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(13,'Lisa Patel','lisa.patel@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(14,'James Kim','james.kim@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(15,'Anna Reyes','anna.reyes@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49'),(16,'Carlos Bautista','carlos.bautista@tsaci.com','worker','$2y$10$E1p3H5qJ9xK7lM2nO3pQ4uRsT5vU6wX7yZ8aB9cD0eF1gH2iJ3kL4','2025-10-15 10:10:49','2025-10-15 10:10:49');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-15 18:36:11

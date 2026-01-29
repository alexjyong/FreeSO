-- FreeSO Database Initialization Script
-- This script creates the necessary database structure for FreeSO

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS fso CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the fso database
USE fso;

-- Create tables for FreeSO (basic structure - actual tables will be created by db-init command)
-- This is a placeholder to ensure the database exists and is accessible

CREATE TABLE IF NOT EXISTS `fso_db_changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `script_name` varchar(255) NOT NULL,
  `applied_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create a basic users table as an example
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL UNIQUE,
  `email` varchar(255) NOT NULL UNIQUE,
  `password_hash` varchar(255) NOT NULL,
  `created_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Grant permissions to the FreeSO server user
GRANT ALL PRIVILEGES ON fso.* TO 'fsoserver'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON fso.* TO 'fsoserver'@'localhost' IDENTIFIED BY 'password';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;
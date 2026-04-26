-- senayan_fix.sql
-- Safe, idempotent schema fixes for SLiMS Bulian.
-- Run this on the database used by your production container.

-- Optional: set target database explicitly (edit as needed)
-- USE `default`;

SELECT DATABASE() AS current_database;

-- Ensure plugins table exists (minimal structure used by app)
CREATE TABLE IF NOT EXISTS `plugins` (
  `id` varchar(32) NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `path` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `uid` int(11) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ensure soft-delete column exists (required by lib/Plugins.php)
ALTER TABLE `plugins`
  ADD COLUMN IF NOT EXISTS `deleted_at` datetime DEFAULT NULL AFTER `updated_at`;

-- Ensure remember-me token table exists (required by lib/Auth/Validator.php)
CREATE TABLE IF NOT EXISTS `user_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `selector` varchar(255) NOT NULL,
  `hashed_validator` varchar(255) NOT NULL,
  `user_id` int NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verification
SHOW TABLES LIKE 'plugins';
SHOW COLUMNS FROM `plugins` LIKE 'deleted_at';
SHOW TABLES LIKE 'user_tokens';

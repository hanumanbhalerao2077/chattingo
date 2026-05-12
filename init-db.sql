-- Chattingo Database Initialization Script
-- This script creates the necessary tables and indexes for Chattingo

-- ============================================
-- User Table
-- ============================================
CREATE TABLE IF NOT EXISTS `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile` varchar(500) COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_name` (`name`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Chat Table
-- ============================================
CREATE TABLE IF NOT EXISTS `chat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chat_image` varchar(500) COLLATE utf8mb4_unicode_ci,
  `chat_name` varchar(255) COLLATE utf8mb4_unicode_ci,
  `is_group` tinyint(1) DEFAULT '0',
  `created_by_id` int,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_created_by` (`created_by_id`),
  KEY `idx_is_group` (`is_group`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_created_by_user` FOREIGN KEY (`created_by_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Chat Users Mapping Table (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS `chat_users` (
  `chat_id` int NOT NULL,
  `users_id` int NOT NULL,
  PRIMARY KEY (`chat_id`, `users_id`),
  KEY `fk_users` (`users_id`),
  CONSTRAINT `fk_chat_users_chat` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_chat_users_user` FOREIGN KEY (`users_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Chat Admins Mapping Table (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS `chat_admins` (
  `chat_id` int NOT NULL,
  `admins_id` int NOT NULL,
  PRIMARY KEY (`chat_id`, `admins_id`),
  KEY `fk_admins` (`admins_id`),
  CONSTRAINT `fk_chat_admins_chat` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_chat_admins_user` FOREIGN KEY (`admins_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Message Table
-- ============================================
CREATE TABLE IF NOT EXISTS `message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` longtext COLLATE utf8mb4_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT '0',
  `chat_id` int,
  `user_id` int,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_chat` (`chat_id`),
  KEY `fk_user` (`user_id`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_message_chat` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_message_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Create Indexes for Performance
-- ============================================
CREATE INDEX IF NOT EXISTS `idx_message_chat_user` ON `message` (`chat_id`, `user_id`);
CREATE INDEX IF NOT EXISTS `idx_message_chat_created` ON `message` (`chat_id`, `created_at`);
CREATE INDEX IF NOT EXISTS `idx_chat_user` ON `chat_users` (`users_id`, `chat_id`);

-- ============================================
-- Insert Sample Data (Optional - for testing)
-- ============================================
-- You can uncomment these lines for testing purposes
-- INSERT INTO `user` (`email`, `name`, `password`) 
-- VALUES ('test@example.com', 'Test User', '$2a$10$slYQmyNdGzin7olVN3dC2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUe');

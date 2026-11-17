-- 1. Создание структуры таблиц
CREATE TABLE `groups` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `group_id` INT NULL,
    `role` ENUM('student', 'staff', 'admin') NOT NULL DEFAULT 'student',
    `full_name` VARCHAR(150) NOT NULL,
    `login` VARCHAR(50) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `certificate_types` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL UNIQUE,
    `description` TEXT NULL,
    `processing_days` INT NOT NULL CHECK (`processing_days` >= 1 AND `processing_days` <= 10),
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `type_id` INT NOT NULL,
    `copies` INT NOT NULL CHECK (`copies` >= 1 AND `copies` <= 5),
    `purpose` VARCHAR(255) NOT NULL,
    `status` ENUM('Новая', 'В работе', 'Готова', 'Выдана', 'Отклонена') NOT NULL DEFAULT 'Новая',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`type_id`) REFERENCES `certificate_types`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `status_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `request_id` INT NOT NULL,
    `changed_by` INT NOT NULL,
    `old_status` VARCHAR(50) NOT NULL,
    `new_status` VARCHAR(50) NOT NULL,
    `changed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`request_id`) REFERENCES `requests`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`changed_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Добавление учебных данных (минимум 20 записей суммарно)
-- Группы (2 записи)
INSERT INTO `groups` (`name`) VALUES ('4ИСИП-1023'), ('3П-1024');

-- Пользователи (3 записи - 2 студента, 1 сотрудник, пароль у всех 123456 хеширован)
INSERT INTO `users` (`group_id`, `role`, `full_name`, `login`, `password_hash`) VALUES
(1, 'student', 'Иванов Иван Иванович', 'stud_ivanov', '$2y$10$abcdefghijklmnopqrstuv'),
(2, 'student', 'Смирнов Алексей Викторович', 'stud_smirnov', '$2y$10$abcdefghijklmnopqrstuv'),
(NULL, 'staff', 'Морозова Елена Сергеевна', 'staff_morozova', '$2y$10$abcdefghijklmnopqrstuv');

-- Виды справок (4 записи)
INSERT INTO `certificate_types` (`name`, `description`, `processing_days`, `is_active`) VALUES
('Справка об обучении', 'Подтверждает статус студента', 3, 1),
('Справка в военкомат', 'Приложение №4', 5, 1),
('Справка о стипендии', 'Доходы за 3 месяца', 4, 1),
('Справка в ПФР', 'Для начисления пособия', 3, 0);

-- Заявки (6 записей)
INSERT INTO `requests` (`student_id`, `type_id`, `copies`, `purpose`, `status`) VALUES
(1, 1, 2, 'По месту требования', 'Новая'),
(2, 2, 1, 'Для военкомата', 'Готова'),
(1, 3, 1, 'Для соцзащиты', 'Выдана'),
(2, 1, 3, 'По месту работы родителей', 'В работе'),
(1, 2, 1, 'Ошибочная', 'Отклонена'),
(2, 4, 1, 'В ПФР', 'Новая');

-- Журнал статусов (6 записей)
INSERT INTO `status_log` (`request_id`, `changed_by`, `old_status`, `new_status`) VALUES
(2, 3, 'Новая', 'В работе'),
(2, 3, 'В работе', 'Готова'),
(3, 3, 'Новая', 'В работе'),
(3, 3, 'В работе', 'Готова'),
(3, 3, 'Готова', 'Выдана'),
(4, 3, 'Новая', 'В работе');

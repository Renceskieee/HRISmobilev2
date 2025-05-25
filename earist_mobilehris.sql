-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 25, 2025 at 02:21 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `earist_mobilehris`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance_record`
--

CREATE TABLE `attendance_record` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `day` varchar(20) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `time` time NOT NULL DEFAULT '00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance_record`
--

INSERT INTO `attendance_record` (`id`, `user_id`, `date`, `day`, `event`, `time`) VALUES
(1, 7, '2025-05-25', 'Sunday', 'Time in', '12:34:22'),
(2, 9, '2025-05-25', 'Sunday', 'Time in', '12:34:25'),
(3, 5, '2025-05-25', 'Sunday', 'Time in', '12:34:27'),
(4, 10, '2025-05-25', 'Sunday', 'Time in', '12:34:29'),
(5, 4, '2025-05-25', 'Sunday', 'Time in', '12:34:31'),
(6, 8, '2025-05-25', 'Sunday', 'Time in', '12:34:33'),
(7, 7, '2025-05-25', 'Sunday', 'Break in', '12:35:18'),
(8, 9, '2025-05-25', 'Sunday', 'Break in', '12:35:22'),
(9, 5, '2025-05-25', 'Sunday', 'Break in', '12:35:25'),
(10, 10, '2025-05-25', 'Sunday', 'Break in', '12:35:27'),
(11, 4, '2025-05-25', 'Sunday', 'Break in', '12:35:29'),
(12, 8, '2025-05-25', 'Sunday', 'Break in', '12:35:31'),
(13, 7, '2025-05-25', 'Sunday', 'Break out', '12:36:11'),
(14, 9, '2025-05-25', 'Sunday', 'Break out', '12:36:13'),
(15, 5, '2025-05-25', 'Sunday', 'Break out', '12:36:25'),
(16, 10, '2025-05-25', 'Sunday', 'Break out', '12:36:27'),
(17, 8, '2025-05-25', 'Sunday', 'Break out', '12:36:28'),
(18, 4, '2025-05-25', 'Sunday', 'Break out', '12:36:38'),
(19, 8, '2025-05-25', 'Sunday', 'Time out', '12:37:19'),
(20, 4, '2025-05-25', 'Sunday', 'Time out', '12:37:21'),
(21, 10, '2025-05-25', 'Sunday', 'Time out', '12:37:23'),
(22, 5, '2025-05-25', 'Sunday', 'Time out', '12:37:27'),
(23, 9, '2025-05-25', 'Sunday', 'Time out', '12:37:29'),
(24, 7, '2025-05-25', 'Sunday', 'Time out', '12:37:32');

-- --------------------------------------------------------

--
-- Table structure for table `holidays`
--

CREATE TABLE `holidays` (
  `id` int(11) NOT NULL,
  `holiday_name` varchar(100) NOT NULL,
  `date` date NOT NULL,
  `type` enum('Regular','Special Non-Working','Special Working') NOT NULL,
  `is_movable` tinyint(1) DEFAULT 0,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `holidays`
--

INSERT INTO `holidays` (`id`, `holiday_name`, `date`, `type`, `is_movable`, `notes`) VALUES
(1, 'New Year\'s Day', '2025-01-01', 'Regular', 0, NULL),
(2, 'Araw ng Kagitingan', '2025-04-09', 'Regular', 0, NULL),
(3, 'Maundy Thursday', '2025-04-17', 'Regular', 1, NULL),
(4, 'Good Friday', '2025-04-18', 'Regular', 1, NULL),
(5, 'Labor Day', '2025-05-01', 'Regular', 0, NULL),
(6, 'Independence Day', '2025-06-12', 'Regular', 0, NULL),
(7, 'National Heroes Day', '2025-08-25', 'Regular', 1, NULL),
(8, 'Bonifacio Day', '2025-11-30', 'Regular', 0, NULL),
(9, 'Christmas Day', '2025-12-25', 'Regular', 0, NULL),
(10, 'Rizal Day', '2025-12-30', 'Regular', 0, NULL),
(11, 'EDSA People Power Anniversary', '2025-02-25', 'Special Non-Working', 0, NULL),
(12, 'Ninoy Aquino Day', '2025-08-21', 'Special Non-Working', 0, NULL),
(13, 'All Saints\' Day', '2025-11-01', 'Special Non-Working', 0, NULL),
(14, 'Feast of the Immaculate Conception', '2025-12-08', 'Special Non-Working', 0, NULL),
(15, 'New Year\'s Eve', '2025-12-31', 'Special Non-Working', 0, NULL),
(16, 'All Souls\' Day', '2025-11-02', 'Special Working', 0, NULL),
(17, 'Christmas Eve', '2025-12-24', 'Special Working', 0, NULL),
(18, 'Laurence Birthday', '2025-05-27', 'Special Non-Working', 0, 'Wishlist: Officially Defended sa Thesis');

-- --------------------------------------------------------

--
-- Table structure for table `leave_request`
--

CREATE TABLE `leave_request` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `leave_type` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `leave_request`
--

INSERT INTO `leave_request` (`id`, `employee_id`, `leave_type`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
(1, 4, 'Vacation Leave', '2025-05-27', '2025-06-01', 'Approved', '2025-05-25 12:11:06', '2025-05-25 12:11:23');

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `leave_request_id` int(11) NOT NULL,
  `status` enum('Pending','Approved','Rejected') NOT NULL,
  `date` date NOT NULL DEFAULT curdate(),
  `time` time NOT NULL DEFAULT curtime()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `role` enum('admin','manager','employee') NOT NULL,
  `password` varchar(255) NOT NULL,
  `employee_number` varchar(50) DEFAULT NULL,
  `f_name` varchar(100) NOT NULL,
  `l_name` varchar(100) NOT NULL,
  `p_pic` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `username`, `role`, `password`, `employee_number`, `f_name`, `l_name`, `p_pic`, `created_at`) VALUES
(4, 'quiniano.lp.bsinfotech@gmail.com', 'Rency', 'admin', '$2b$10$upKUmhN6DDdN7Z1M/iZYMOWIJNztVm9BJnD.7LZSCvbsBVHRIrqHK', '20130527M', 'Laurence Paul', 'Quiniano', '1747820602326-614508271.png', '2025-05-04 13:11:47'),
(5, 'deguzman.n.bsinfotech@gmail.com', 'Enkae', 'employee', '$2b$10$Nxma8qLtbcfYohoi/zcJOeCC9yoZnhpf7LJq0Pc66LBCZUYg1KAwq', '20130111F', 'Nikki', 'De Guzman', '1746447149994-504118102.jpg', '2025-05-05 12:12:30'),
(7, 'baliciado.r.bsinfotech@gmail.com', 'Vena', 'manager', '$2b$10$kZC76UucwFPLQ5ZZpOlWy.TGe/7p4dcbKW9qbvNbdX5JMNnKLHLiy', '20130112F', 'Raven', 'Baliciado', '1746448669859-172199255.jpg', '2025-05-05 12:37:49'),
(8, 'yang.ea.bsinfotech2@gmail.com', 'yangyang', 'employee', '$2b$10$/AVGxqkK0fRAcJ5IulUiwuHqc2WrR/fskQ61rxl1LGIKrTP1uNCJC', '20130113F', 'Ericka Anne', 'Yang', '1746449768119-811781185.jpg', '2025-05-05 12:56:09'),
(9, 'cua.pa.bstm@gmail.com', 'Iamplndrc', 'admin', '$2b$10$G/SyyI/fCE8Qca8f.otCYO5hbaJRAg25QugdlDFTHaelrNQufQIha', '20130219F', 'Paula Andrea', 'Cua', '1747392069858-882872590.jpg', '2025-05-16 10:34:55'),
(10, 'quiniano.ap.bsed@gmail.com', 'Aali', 'employee', '$2b$10$aiQpI/Gz/Fk7b59g4urbFe.fPDO5Z8Iu3pGzwC4ht8uw0cVQZ.dYK', '20130828F', 'Aaliyah Paula', 'Quiniano', '1747830574228-178664623.JPG', '2025-05-21 12:29:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance_record`
--
ALTER TABLE `attendance_record`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `holidays`
--
ALTER TABLE `holidays`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leave_request`
--
ALTER TABLE `leave_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_leave_user` (`employee_id`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `leave_request_id` (`leave_request_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `employee_number` (`employee_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance_record`
--
ALTER TABLE `attendance_record`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `holidays`
--
ALTER TABLE `holidays`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `leave_request`
--
ALTER TABLE `leave_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `attendance_record`
--
ALTER TABLE `attendance_record`
  ADD CONSTRAINT `attendance_record_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `leave_request`
--
ALTER TABLE `leave_request`
  ADD CONSTRAINT `fk_leave_user` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `notification_ibfk_2` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_request` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

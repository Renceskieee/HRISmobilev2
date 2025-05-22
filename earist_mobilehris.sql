-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 21, 2025 at 07:12 PM
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

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `leave_request_id` int(11) NOT NULL,
  `status` enum('Pending','Approved','Rejected') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
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
-- AUTO_INCREMENT for table `leave_request`
--
ALTER TABLE `leave_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

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

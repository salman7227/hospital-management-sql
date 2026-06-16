-- ============================================================
-- HOSPITAL MANAGEMENT SYSTEM — DATABASE SCHEMA
-- Author: Salman Humer Khan
-- Engine: MySQL 8.0
-- ============================================================

DROP DATABASE IF EXISTS hospital_management;
CREATE DATABASE hospital_management;
USE hospital_management;

-- ----------------------------------------------------------
-- Table: departments
-- ----------------------------------------------------------
CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    floor_number     INT,
    head_doctor_id   INT NULL
);

-- ----------------------------------------------------------
-- Table: doctors
-- ----------------------------------------------------------
CREATE TABLE doctors (
    doctor_id        INT AUTO_INCREMENT PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    specialization   VARCHAR(100) NOT NULL,
    department_id    INT,
    phone            VARCHAR(15),
    email            VARCHAR(100) UNIQUE,
    years_experience INT DEFAULT 0,
    consultation_fee DECIMAL(8,2) DEFAULT 500.00,
    joining_date     DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Add FK from departments -> doctors (head doctor) after doctors table exists
ALTER TABLE departments
    ADD CONSTRAINT fk_head_doctor
    FOREIGN KEY (head_doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE SET NULL;

-- ----------------------------------------------------------
-- Table: patients
-- ----------------------------------------------------------
CREATE TABLE patients (
    patient_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    date_of_birth  DATE NOT NULL,
    gender         ENUM('Male','Female','Other') NOT NULL,
    phone          VARCHAR(15),
    email          VARCHAR(100),
    address        VARCHAR(200),
    city           VARCHAR(50),
    blood_group    VARCHAR(5),
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- ----------------------------------------------------------
-- Table: appointments
-- ----------------------------------------------------------
CREATE TABLE appointments (
    appointment_id   INT AUTO_INCREMENT PRIMARY KEY,
    patient_id       INT NOT NULL,
    doctor_id        INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status           ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    reason           VARCHAR(200),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- Table: treatments
-- ----------------------------------------------------------
CREATE TABLE treatments (
    treatment_id     INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id   INT NOT NULL,
    diagnosis        VARCHAR(200),
    treatment_desc   VARCHAR(300),
    prescribed_meds  VARCHAR(300),
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date   DATE NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- Table: billing
-- ----------------------------------------------------------
CREATE TABLE billing (
    bill_id          INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id   INT NOT NULL,
    consultation_fee DECIMAL(8,2) NOT NULL,
    medicine_charges DECIMAL(8,2) DEFAULT 0,
    test_charges     DECIMAL(8,2) DEFAULT 0,
    total_amount     DECIMAL(8,2) GENERATED ALWAYS AS
                        (consultation_fee + medicine_charges + test_charges) STORED,
    payment_status   ENUM('Paid','Pending','Partially Paid') DEFAULT 'Pending',
    payment_method   ENUM('Cash','UPI','Card','Insurance') NULL,
    bill_date        DATE NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- Indexes for performance
-- ----------------------------------------------------------
CREATE INDEX idx_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_doctor_specialization ON doctors(specialization);
CREATE INDEX idx_billing_status ON billing(payment_status);

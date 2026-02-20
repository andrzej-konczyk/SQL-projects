-- ============================================================
-- DROPS - always clean up first (reverse FK order for FKs)
-- ============================================================

-- 3NF
DROP TABLE IF EXISTS billing_3nf CASCADE;
DROP TABLE IF EXISTS treatment_records_3nf CASCADE;
DROP TABLE IF EXISTS appointments_3nf CASCADE;
DROP TABLE IF EXISTS doctors_3nf CASCADE;
DROP TABLE IF EXISTS patients_3nf CASCADE;
DROP TABLE IF EXISTS locations CASCADE;

-- 2NF
DROP TABLE IF EXISTS billing_2nf CASCADE;
DROP TABLE IF EXISTS treatment_records_2nf CASCADE;
DROP TABLE IF EXISTS appointments_2nf CASCADE;
DROP TABLE IF EXISTS patients_2nf CASCADE;
DROP TABLE IF EXISTS doctors_2nf CASCADE;

-- Słowniki 2NF
DROP TABLE IF EXISTS treatment_types CASCADE;
DROP TABLE IF EXISTS insurance_providers CASCADE;
DROP TABLE IF EXISTS hospital_branches CASCADE;
DROP TABLE IF EXISTS specializations CASCADE;

-- 1NF
DROP TABLE IF EXISTS billing_1nf CASCADE;
DROP TABLE IF EXISTS treatments_1nf CASCADE;
DROP TABLE IF EXISTS appointments_1nf CASCADE;
DROP TABLE IF EXISTS patients_1nf CASCADE;
DROP TABLE IF EXISTS doctors_1nf CASCADE;


-- ============================================================
-- STEP 1: 1NF
-- Goal: atomic values, proper data types, address split into components
-- ============================================================

CREATE TABLE doctors_1nf (
    doctor_id        TEXT,
    first_name       TEXT,
    last_name        TEXT,
    specialization   TEXT,
    phone_number     TEXT,
    years_experience INT,
    hospital_branch  TEXT,
    email            TEXT
);

INSERT INTO doctors_1nf
SELECT 
    doctor_id,
    first_name,
    last_name,
    specialization,
    phone_number,
    years_experience::INT,
    hospital_branch,
    email
FROM doctors;

-- Split the free‑text address into street_address + city (atomic values for 1NF)
CREATE TABLE patients_1nf (
    patient_id        TEXT,
    first_name        TEXT,
    last_name         TEXT,
    gender            TEXT,
    date_of_birth     DATE,
    contact_number    TEXT,
    street_address    TEXT,
    city              TEXT,
    registration_date DATE,
    insurance_provider TEXT,
    insurance_number  TEXT,
    email             TEXT
);

INSERT INTO patients_1nf
SELECT 
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth::DATE,
    contact_number,
    SPLIT_PART(address, ',', 1)       AS street_address,
    TRIM(SPLIT_PART(address, ',', 2)) AS city,
    registration_date::DATE,
    insurance_provider,
    insurance_number,
    email
FROM patients;

-- Cast date and time columns to proper types
CREATE TABLE appointments_1nf (
    appointment_id   TEXT,
    patient_id       TEXT,
    doctor_id        TEXT,
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit TEXT,
    status           TEXT
);

INSERT INTO appointments_1nf
SELECT
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date::DATE,
    appointment_time::TIME,
    reason_for_visit,
    status
FROM appointments;

CREATE TABLE treatments_1nf (
    treatment_id   TEXT,
    appointment_id TEXT,
    treatment_type TEXT,
    description    TEXT,
    cost           NUMERIC(10,2),
    treatment_date DATE
);

INSERT INTO treatments_1nf
SELECT 
    treatment_id,
    appointment_id,
    treatment_type,
    description,
    cost::NUMERIC,
    treatment_date::DATE
FROM treatments;

CREATE TABLE billing_1nf (
    bill_id        TEXT,
    patient_id     TEXT,
    treatment_id   TEXT,
    bill_date      DATE,
    amount         NUMERIC(10,2),
    payment_method TEXT,
    payment_status TEXT
);

INSERT INTO billing_1nf
SELECT
    bill_id,
    patient_id,
    treatment_id,
    bill_date::DATE,
    amount::NUMERIC,
    payment_method,
    payment_status
FROM billing;


-- ============================================================
-- STEP 2: 2NF
-- Goal: eliminate repeated data via lookup tables (dimension tables)
-- Each non‑key column must depend on the WHOLE primary key
-- ============================================================

-- Lookup tables: extract attributes that repeat across many rows

CREATE TABLE specializations (
    specialization_id   SERIAL PRIMARY KEY,
    specialization_name TEXT UNIQUE NOT NULL
);

CREATE TABLE hospital_branches (
    branch_id   SERIAL PRIMARY KEY,
    branch_name TEXT UNIQUE NOT NULL
);

CREATE TABLE insurance_providers (
    provider_id   SERIAL PRIMARY KEY,
    provider_name TEXT UNIQUE NOT NULL
);

-- treatment_type repeats for many treatments – move it to a lookup table
CREATE TABLE treatment_types (
    type_id   SERIAL PRIMARY KEY,
    name      TEXT UNIQUE NOT NULL,
    base_cost NUMERIC(10,2)  -- average cost used as a reference value
);

--INSERTS

INSERT INTO specializations (specialization_name)
SELECT DISTINCT specialization 
FROM doctors_1nf 
WHERE specialization IS NOT NULL;

INSERT INTO hospital_branches (branch_name)
SELECT DISTINCT hospital_branch 
FROM doctors_1nf 
WHERE hospital_branch IS NOT NULL;

INSERT INTO insurance_providers (provider_name)
SELECT DISTINCT insurance_provider 
FROM patients_1nf 
WHERE insurance_provider IS NOT NULL;

INSERT INTO treatment_types (name, base_cost)
SELECT 
    treatment_type,
    AVG(cost)
FROM treatments_1nf
GROUP BY treatment_type;

-- Main 2NF tables – store foreign keys to lookup tables instead of duplicated text

CREATE TABLE doctors_2nf (
    doctor_id         TEXT PRIMARY KEY,
    first_name        TEXT NOT NULL,
    last_name         TEXT NOT NULL,
    specialization_id INT REFERENCES specializations(specialization_id),
    branch_id         INT REFERENCES hospital_branches(branch_id),
    years_experience  INT,
    phone_number      TEXT,
    email             TEXT
);

INSERT INTO doctors_2nf
SELECT 
    d.doctor_id,
    d.first_name,
    d.last_name,
    s.specialization_id,
    b.branch_id,
    d.years_experience,
    d.phone_number,
    d.email
FROM doctors_1nf d
LEFT JOIN specializations s   ON d.specialization  = s.specialization_name
LEFT JOIN hospital_branches b ON d.hospital_branch = b.branch_name;

CREATE TABLE patients_2nf (
    patient_id            TEXT PRIMARY KEY,
    first_name            TEXT NOT NULL,
    last_name             TEXT NOT NULL,
    gender                TEXT,
    date_of_birth         DATE,
    contact_number        TEXT,
    street_address        TEXT,
    city                  TEXT,
    registration_date     DATE,
    insurance_provider_id INT REFERENCES insurance_providers(provider_id),
    insurance_number      TEXT,
    email                 TEXT
);

INSERT INTO patients_2nf
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    p.gender,
    p.date_of_birth,
    p.contact_number,
    p.street_address,
    p.city,
    p.registration_date,
    ip.provider_id,
    p.insurance_number,
    p.email
FROM patients_1nf p
LEFT JOIN insurance_providers ip ON p.insurance_provider = ip.provider_name;

CREATE TABLE appointments_2nf (
    appointment_id   TEXT PRIMARY KEY,
    patient_id       TEXT REFERENCES patients_2nf(patient_id),
    doctor_id        TEXT REFERENCES doctors_2nf(doctor_id),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit TEXT,
    status           TEXT
);

INSERT INTO appointments_2nf
SELECT 
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date,
    appointment_time,
    reason_for_visit,
    status
FROM appointments_1nf;

-- Junction table linking an appointment with a treatment type.
-- actual_cost may differ from the base_cost stored in the lookup table.
CREATE TABLE treatment_records_2nf (
    treatment_id   TEXT PRIMARY KEY,
    appointment_id TEXT REFERENCES appointments_2nf(appointment_id),
    type_id        INT  REFERENCES treatment_types(type_id),
    actual_cost    NUMERIC(10,2),
    treatment_date DATE,
    description    TEXT
);

INSERT INTO treatment_records_2nf
SELECT 
    t.treatment_id,
    t.appointment_id,
    tt.type_id,
    t.cost,
    t.treatment_date,
    t.description
FROM treatments_1nf t
LEFT JOIN treatment_types tt ON t.treatment_type = tt.name;

-- Remove patient_id from billing: the patient is implied by the chain
-- billing → treatment_record → appointment → patient
CREATE TABLE billing_2nf (
    bill_id        TEXT PRIMARY KEY,
    treatment_id   TEXT REFERENCES treatment_records_2nf(treatment_id),
    bill_date      DATE NOT NULL,
    amount         NUMERIC(10,2) NOT NULL,
    payment_method TEXT,
    payment_status TEXT
);

INSERT INTO billing_2nf
SELECT 
    b.bill_id,
    b.treatment_id,
    b.bill_date,
    b.amount,
    b.payment_method,
    b.payment_status
FROM billing_1nf b;


-- ============================================================
-- STEP 3: 3NF
-- Goal: eliminate transitive dependencies
-- Example: patient_id → city → zip_code
-- zip_code depends on city, not directly on the patient – move it out
-- ============================================================

-- Location as a separate entity – the city has its own attributes (e.g. zip_code)
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    city        TEXT NOT NULL,
    zip_code    TEXT
);

INSERT INTO locations (city)
SELECT DISTINCT city 
FROM patients_2nf 
WHERE city IS NOT NULL;

-- PATIENTS 3NF: city is replaced by location_id
CREATE TABLE patients_3nf (
    patient_id            TEXT PRIMARY KEY,
    first_name            TEXT NOT NULL,
    last_name             TEXT NOT NULL,
    gender                TEXT,
    date_of_birth         DATE,
    contact_number        TEXT,
    street_address        TEXT,
    location_id           INT REFERENCES locations(location_id),
    registration_date     DATE,
    insurance_provider_id INT REFERENCES insurance_providers(provider_id),
    insurance_number      TEXT,
    email                 TEXT
);

INSERT INTO patients_3nf
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    p.gender,
    p.date_of_birth,
    p.contact_number,
    p.street_address,
    l.location_id,
    p.registration_date,
    p.insurance_provider_id,
    p.insurance_number,
    p.email
FROM patients_2nf p
LEFT JOIN locations l ON p.city = l.city;

-- The remaining tables do not have transitive dependencies.
-- Recreate them with explicit FK constraints (do not use CREATE TABLE AS, as it does not copy constraints).

CREATE TABLE doctors_3nf (
    doctor_id         TEXT PRIMARY KEY,
    first_name        TEXT NOT NULL,
    last_name         TEXT NOT NULL,
    specialization_id INT REFERENCES specializations(specialization_id),
    branch_id         INT REFERENCES hospital_branches(branch_id),
    years_experience  INT,
    phone_number      TEXT,
    email             TEXT
);

CREATE TABLE appointments_3nf (
    appointment_id   TEXT PRIMARY KEY,
    patient_id       TEXT REFERENCES patients_3nf(patient_id),  -- references the 3NF patients table
    doctor_id        TEXT REFERENCES doctors_3nf(doctor_id),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit TEXT,
    status           TEXT
);

CREATE TABLE treatment_records_3nf (
    treatment_id   TEXT PRIMARY KEY,
    appointment_id TEXT REFERENCES appointments_3nf(appointment_id),
    type_id        INT  REFERENCES treatment_types(type_id),
    actual_cost    NUMERIC(10,2),
    treatment_date DATE,
    description    TEXT
);

CREATE TABLE billing_3nf (
    bill_id        TEXT PRIMARY KEY,
    treatment_id   TEXT REFERENCES treatment_records_3nf(treatment_id),
    bill_date      DATE NOT NULL,
    amount         NUMERIC(10,2) NOT NULL,
    payment_method TEXT,
    payment_status TEXT
);

-- INSERTS
INSERT INTO doctors_3nf          SELECT * FROM doctors_2nf;
INSERT INTO appointments_3nf     SELECT * FROM appointments_2nf;
INSERT INTO treatment_records_3nf SELECT * FROM treatment_records_2nf;

INSERT INTO billing_3nf          SELECT * FROM billing_2nf;

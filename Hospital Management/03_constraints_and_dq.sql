-- ==========================================
-- STEP 03: CONSTRAINTS & DATA QUALITY
-- ==========================================

-- 1.1. Business integrity (non‑negative monetary values)
ALTER TABLE billing_3nf 
ADD CONSTRAINT chk_positive_billing_amount CHECK (amount >= 0);

ALTER TABLE treatment_types 
ADD CONSTRAINT chk_positive_base_cost CHECK (base_cost >= 0);

-- 1.2. Domain validation (allowed values)
ALTER TABLE appointments_3nf 
ADD CONSTRAINT chk_valid_appointment_status 
CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No-show'));

ALTER TABLE billing_3nf 
ADD CONSTRAINT chk_valid_payment_status 
CHECK (payment_status IN ('Paid', 'Pending', 'Failed'));

-- 1.3. Temporal logic (critical for data quality)
-- A patient cannot register before their date of birth
ALTER TABLE patients_3nf 
ADD CONSTRAINT chk_registration_after_birth 
CHECK (registration_date >= date_of_birth);

-- A treatment should not take place before the “modern era” of the system;
-- for full enforcement you would use triggers or application‑level validation,
-- here we add a simple lower‑bound check on the date.
ALTER TABLE treatment_records_3nf 
ADD CONSTRAINT chk_modern_treatment_date 
CHECK (treatment_date > '1900-01-01');

-- 2.1. Completeness checks
-- Patients without phone number or email (critical for notifications/marketing)
CREATE OR REPLACE VIEW dq_missing_contact_info AS
SELECT patient_id, first_name, last_name, email, contact_number
FROM patients_3nf
WHERE email IS NULL OR contact_number IS NULL OR email = '';

select * from dq_missing_contact_info;

-- 2.2. Format validation (validity)
-- Detect invalid email patterns
CREATE OR REPLACE VIEW dq_invalid_emails AS
SELECT patient_id, email
FROM patients_3nf
WHERE email NOT SIMILAR TO '%_@__%.__%';

select * from dq_invalid_emails;

-- 2.3. Financial consistency
-- Check whether billed amount equals the treatment cost
CREATE OR REPLACE VIEW dq_billing_cost_mismatch AS
SELECT 
    b.bill_id, 
    b.amount AS billed_amount, 
    t.actual_cost AS treatment_cost,
    (b.amount - t.actual_cost) AS discrepancy
FROM billing_3nf b
JOIN treatment_records_3nf t ON b.treatment_id = t.treatment_id
WHERE b.amount <> t.actual_cost;

select * from dq_billing_cost_mismatch;

CREATE INDEX idx_appointment_patient ON appointments_3nf(patient_id);
CREATE INDEX idx_appointment_doctor ON appointments_3nf(doctor_id);
CREATE INDEX idx_treatment_appointment ON treatment_records_3nf(appointment_id);
CREATE INDEX idx_billing_treatment ON billing_3nf(treatment_id);
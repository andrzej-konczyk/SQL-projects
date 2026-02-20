CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.patients (
    patient_id TEXT, first_name TEXT, last_name TEXT, gender TEXT,
    date_of_birth TEXT, contact_number TEXT, address TEXT,
    registration_date TEXT, insurance_provider TEXT, insurance_number TEXT, email TEXT
);

CREATE TABLE staging.doctors (
    doctor_id TEXT, first_name TEXT, last_name TEXT, specialization TEXT,
    phone_number TEXT, years_experience TEXT, hospital_branch TEXT, email TEXT
);

CREATE TABLE staging.appointments (
    appointment_id TEXT, patient_id TEXT, doctor_id TEXT, appointment_date TEXT,
    appointment_time TEXT, reason_for_visit TEXT, status TEXT
);

CREATE TABLE staging.treatments (
    treatment_id TEXT, appointment_id TEXT, treatment_type TEXT, description TEXT,
    cost TEXT
);

CREATE TABLE staging.billing (
    bill_id TEXT, patient_id TEXT, treatment_id TEXT, bill_date TEXT,
    amount TEXT, payment_method TEXT, payment_status TEXT
);
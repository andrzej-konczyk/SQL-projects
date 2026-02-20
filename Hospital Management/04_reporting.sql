CREATE OR REPLACE VIEW report_department_performance AS
SELECT 
    hb.branch_name,
    s.specialization_name,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    SUM(b.amount) AS total_revenue,
    ROUND(AVG(b.amount), 2) AS avg_bill_value
FROM hospital_branches hb
JOIN doctors_3nf d ON hb.branch_id = d.branch_id
JOIN specializations s ON d.specialization_id = s.specialization_id
JOIN appointments_3nf a ON d.doctor_id = a.doctor_id
JOIN treatment_records_3nf tr ON a.appointment_id = tr.appointment_id
JOIN billing_3nf b ON tr.treatment_id = b.treatment_id
WHERE b.payment_status = 'Paid'
GROUP BY hb.branch_name, s.specialization_name
ORDER BY total_revenue DESC;

select * from report_department_performance;

CREATE OR REPLACE VIEW report_billing_by_status_method AS
SELECT 
    payment_status,
    payment_method,
    COUNT(*) AS bill_count,
    SUM(amount) AS total_amount,
    ROUND((SUM(amount) / SUM(SUM(amount)) OVER()) * 100, 2) AS percentage_of_total
FROM billing_3nf
GROUP BY payment_status, payment_method;

select * from report_billing_by_status_method;

CREATE OR REPLACE VIEW report_doctor_workload AS
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    s.specialization_name,
    COUNT(a.appointment_id) AS patient_count,
    RANK() OVER (ORDER BY COUNT(a.appointment_id) DESC) as workload_rank
FROM doctors_3nf d
JOIN specializations s ON d.specialization_id = s.specialization_id
JOIN appointments_3nf a ON d.doctor_id = a.doctor_id
WHERE a.status = 'Completed'
GROUP BY d.doctor_id, d.first_name, d.last_name, s.specialization_name;

select * from report_doctor_workload;

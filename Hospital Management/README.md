## Hospital Management – SQL Normalization & Reporting

This project demonstrates how to take raw hospital operational data, normalize it from a staging layer into 3NF, apply data‑quality controls, and expose a small reporting layer, using PostgreSQL.

### 1. Technology assumptions

- **Database**: PostgreSQL (uses `SIMILAR TO`, `SERIAL`, `NUMERIC`, etc.)
- **Input**: CSV or similar files imported into the `staging` schema / IDE import tools.

### 2. Source data model (staging)

The script `00_init_staging.sql` creates a **staging schema** with raw, text‑typed tables:

- `staging.patients`
- `staging.doctors`
- `staging.appointments`
- `staging.treatments`
- `staging.billing`

All columns are stored as `TEXT` here to simplify ingestion; no constraints are enforced at this layer.

#### 2.1. Staging ERD

Staging layer relationships visualized:

![Staging ERD](img1.png)

### 3. Load raw data

The script `01_load_data.sql` assumes that the raw data has already been imported (e.g. via IDE import) into base tables:

- `patients`
- `doctors`
- `appointments`
- `treatments`
- `billing`

It simply selects from these tables to allow quick visual checks that the import succeeded and that basic row counts / shapes look reasonable.

### 4. Normalization pipeline (1NF → 2NF → 3NF)

The core modeling work lives in `02_normalization.sql`. It builds the normalized schema in three stages:

- **1NF tables**
  - `doctors_1nf`, `patients_1nf`, `appointments_1nf`, `treatments_1nf`, `billing_1nf`
  - Key actions:
    - Convert date/time and numeric fields from `TEXT` into proper `DATE`, `TIME`, and `NUMERIC` types.
    - Split the free‑text `address` into `street_address` and `city` for patients (atomic values).

- **2NF tables and lookup dimensions**
  - Lookup tables:
    - `specializations`, `hospital_branches`, `insurance_providers`, `treatment_types`
  - Core 2NF tables:
    - `doctors_2nf`, `patients_2nf`, `appointments_2nf`,
      `treatment_records_2nf`, `billing_2nf`
  - Key actions:
    - Replace repeated descriptive text (e.g. specialization names, hospital branches, insurance providers, treatment types) with **foreign keys** to lookup tables.
    - Introduce `treatment_records_2nf` as a junction between appointments and treatment types, storing `actual_cost` separate from the lookup’s `base_cost`.
    - Remove `patient_id` from `billing` so the patient is implied by the chain  
      `billing → treatment_record → appointment → patient`.

- **3NF tables**
  - New 3NF entities:
    - `locations` (city‑level attributes, such as `zip_code`)
    - `patients_3nf` (uses `location_id` instead of city text)
  - 3NF core tables:
    - `doctors_3nf`, `appointments_3nf`, `treatment_records_3nf`, `billing_3nf`
  - Key actions:
    - Remove transitive dependency `patient_id → city → zip_code` by moving city and related attributes into `locations`.
    - Recreate the other core tables with explicit primary and foreign keys and load data from the 2NF layer.

The top of `02_normalization.sql` also contains `DROP TABLE IF EXISTS ... CASCADE` statements for all 1NF/2NF/3NF and lookup tables so the script is **idempotent** and can be rerun.

#### 4.1. 3NF ERD (final model)

Final 3NF data model and lookup tables:

![3NF ERD](img2.png)

### 5. Constraints & data quality checks

The script `03_constraints_and_dq.sql` adds business rules and creates DQ views on top of the **3NF tables**:

- **Integrity & domain constraints**
  - Non‑negative amounts:
    - `chk_positive_billing_amount` on `billing_3nf.amount`
    - `chk_positive_base_cost` on `treatment_types.base_cost`
  - Enumerated domains:
    - `chk_valid_appointment_status` on `appointments_3nf.status`
    - `chk_valid_payment_status` on `billing_3nf.payment_status`

- **Temporal logic**
  - `chk_registration_after_birth` on `patients_3nf`: registration date must be on or after date of birth.
  - `chk_modern_treatment_date` on `treatment_records_3nf`: enforce a lower bound on treatment dates (simple system sanity check).

- **Data quality views**
  - `dq_missing_contact_info` – patients missing email or phone.
  - `dq_invalid_emails` – email values not matching a basic pattern.
  - `dq_billing_cost_mismatch` – discrepancies between `billing_3nf.amount` and `treatment_records_3nf.actual_cost`.

- **Indexes**
  - Cover common join/filter paths:
    - `appointments_3nf(patient_id)`, `appointments_3nf(doctor_id)`
    - `treatment_records_3nf(appointment_id)`
    - `billing_3nf(treatment_id)`

These objects ensure that the 3NF layer is both **trusted for quality** and reasonably performant for analytics.

### 6. Reporting layer

The script `04_reporting.sql` defines reusable views for analysis, all built on the 3NF model:

- `report_department_performance`
  - Revenue and activity by hospital branch and specialization.
  - Uses `hospital_branches`, `specializations`, `doctors_3nf`, `appointments_3nf`, `treatment_records_3nf`, `billing_3nf`.
  - Includes total appointments, total revenue, and average bill value for paid bills.

- `report_billing_by_status_method`
  - Aggregation of billing by `payment_status` and `payment_method`, including share of total revenue.

- `report_doctor_workload`
  - Number of completed appointments per doctor, with a ranking to understand workload distribution.

Each view is followed by a simple `SELECT *` for quick inspection, but in practice these views are intended as stable interfaces for dashboards or BI tools.

### 7. Recommended execution order

In a fresh database (or when you want to rebuild the model), run the scripts in this order:

1. `00_init_staging.sql` – create staging schema and raw tables.
2. Import raw data into `staging.*` (or base) tables using your IDE or ETL tool.
3. `01_load_data.sql` – optional quick sanity check of loaded raw tables.
4. `02_normalization.sql` – build and populate 1NF, 2NF, and 3NF structures.
5. `03_constraints_and_dq.sql` – enforce constraints and create DQ views/indexes.
6. `04_reporting.sql` – create reporting views and run sample queries.

### 8. How to run (example with psql)

From the project directory:

```bash
psql -U <user> -d <database> -f 00_init_staging.sql
psql -U <user> -d <database> -f 01_load_data.sql
psql -U <user> -d <database> -f 02_normalization.sql
psql -U <user> -d <database> -f 03_constraints_and_dq.sql
psql -U <user> -d <database> -f 04_reporting.sql
```

Adjust the user, database name, and connection parameters as needed.



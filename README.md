# HR Attrition Analysis (MySQL + Power BI)

Cleaning raw HR records in MySQL and analysing workforce composition and attrition, to help HR see **who is leaving, from where, and when**.

## Business problem

Losing employees is expensive: hiring, onboarding and lost productivity all cost money. HR leadership wants to know:

- What does the current workforce look like (size, gender, age, location)?
- Which departments and job titles have the highest attrition?
- At what stage of tenure do people leave?
- Are recent hiring cohorts staying longer than older ones?

## Dataset

- **Source:** `Human Resources.csv`, taken from a public GitHub repository
- **Size:** ~22,000 employee records hired between 2000 and 2020
- **Columns:** id, name, birthdate, gender, race, department, job title, location (HQ/remote), hire date, termination date, city, state
- **Issues in the raw data:** dates stored as text in 3 different formats, 2-digit birth years, blank termination dates, and hidden `\r` characters at the end of each line

## Approach

### 1. Data cleaning: 
- Loaded the CSV into a raw table with all columns as text
- Parsed birth and hire dates from 3 formats (`mm/dd/yyyy`, `mm-dd-yyyy`, `mm-dd-yy`) using `CASE`, `REGEXP` and `STR_TO_DATE`
- Fixed 2-digit birth years read as future dates (e.g. 2065 → 1965)
- Converted termination timestamps to dates; blank means still employed (`NULL`)
- Removed hidden `\r` characters from the last column
- Calculated age, then ran quality checks: NULLs, impossible ages, exit before hire, hired before birth, duplicate IDs

### 2. Business questions: 
An employee is **active** if they have no exit date or their exit date is in the future (serving notice).

| # | Question |
|---|---|
| Q1–Q4 | Workforce breakdown by gender, race, age group and HQ vs remote |
| Q5 | Average tenure of employees who left |
| Q6–Q7 | Gender by department, and job title distribution |
| Q8 | Attrition rate by department |
| Q9 | Employees by state and city |
| Q10 | Retention rate by hire year (cohort analysis) |
| Q11 | KPI summary for the dashboard cards |
| Q12 | Top 10 job titles by attrition (only titles with 50+ staff) |
| Q13 | Exits by tenure band, as a share of all exits |

**SQL used:** `CASE`, `REGEXP`, `STR_TO_DATE`, `DATEDIFF`, `TIMESTAMPDIFF`, subqueries, `GROUP BY` / `HAVING`, and window functions (`SUM() OVER()`)

### 3. Dashboard (Power BI)
Two pages: **Workforce overview** and **Attrition drivers**, with a department slicer.

## Key findings

| KPI | Value |
|---|---|
| Total employees (ever hired) | 22K |
| Active employees | 19K |
| Exits | 3K |
| Attrition rate | 13.1% |
| Average age (active) | 42.1 years |
| Average tenure of leavers | 8.5 years |

- **Workforce:** 51% male, 46% female, 3% non-conforming. 75% work at headquarters and 25% remotely.
- **Location:** Ohio holds most of the workforce. Engineering is the largest department.
- **Departments:** Auditing and Legal have the highest attrition, well above the company average of 13.1%.
- **Job titles:** Paralegal has the highest attrition among roles with 50+ staff.
- **Tenure:** most people who leave do so after **5+ years**, not early. Retention efforts should therefore target experienced staff, not only new joiners.
- **Hiring cohorts:** recent hires show higher retention than people hired in the early 2000s, as expected because they have had less time to leave.

## Note on the attrition rate

13.1% is **cumulative** attrition: exits ÷ everyone ever hired since 2000. It is not an annual rate. Results are calculated as of the date the queries were run (8 Nov 2026), because "active" and "age" depend on `CURDATE()`.

## Tools

MySQL 8 · MySQL Workbench · Power BI

## Repository structure

```
├── sql/
│   ├── 01_data_cleaning.sql
│   └── 02_business_questions.sql
├── images/
│   ├── hr_overview.png
│   └── hr_attrition_drivers.png
└── README.md
```

---
**Author:** Aastha Verma · [LinkedIn](https://www.linkedin.com/in/verma-aastha)

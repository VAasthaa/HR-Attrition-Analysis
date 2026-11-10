
USE hr_analytics;

SELECT COUNT(*)                                AS total,
       SUM(termdate IS NULL)                   AS active_no_exit_date,
       SUM(termdate > CURDATE())               AS active_future_exit,
       SUM(termdate <= CURDATE())              AS terminated_count
FROM hr_data;


-- #Q1 Gender breakdown (active employees)
SELECT gender, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY gender
ORDER BY count DESC;

-- #Q2 Race/ethnicity breakdown
SELECT race, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY race
ORDER BY count DESC;

-- #Q3 Age distribution: min/max, then age bands by gender
SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE();

SELECT CASE
         WHEN age BETWEEN 18 AND 24 THEN '18-24'
         WHEN age BETWEEN 25 AND 34 THEN '25-34'
         WHEN age BETWEEN 35 AND 44 THEN '35-44'
         WHEN age BETWEEN 45 AND 54 THEN '45-54'
         ELSE '55+'
       END AS age_group,
       gender,
       COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- #Q4 Headquarters vs remote
SELECT location, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY location;

-- #Q5 Average tenure of leavers, in years (1 decimal, not rounded to a whole number)
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date)) / 365, 1) AS avg_tenure_years
FROM hr_data
WHERE termdate <= CURDATE();

-- #Q6 Gender by department
SELECT department, gender, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY department, gender
ORDER BY department, gender;

-- #Q7 Job title distribution
SELECT jobtitle, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY jobtitle
ORDER BY count DESC;

-- #Q8 Turnover rate by department
SELECT department, total_count, terminated_count,
       ROUND(terminated_count / total_count * 100, 2) AS termination_rate
FROM (
  SELECT department,
         COUNT(*) AS total_count,
         SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
  FROM hr_data
  GROUP BY department
) AS sub
ORDER BY termination_rate DESC;

-- #Q9 Employees by state and city
SELECT location_state AS state, location_city AS city, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY state, city
ORDER BY state, city;

SELECT location_state AS state, COUNT(*) AS count
FROM hr_data
WHERE termdate IS NULL OR termdate > CURDATE()
GROUP BY state
ORDER BY count DESC;

-- #Q10 Hiring cohorts: of the people hired each year, how many have left?
SELECT year, hires, terminations,
       hires - terminations                              AS still_employed,
       ROUND((hires - terminations) / hires * 100, 2)    AS retention_rate
FROM (
  SELECT YEAR(hire_date) AS year,
         COUNT(*) AS hires,
         SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
  FROM hr_data
  GROUP BY year
) AS sub
ORDER BY year;

-- #Q11 KPI summary (one row for the dashboard cards)
SELECT COUNT(*)                                                  AS total_ever_hired,
       SUM(termdate IS NULL OR termdate > CURDATE())             AS active_headcount,
       SUM(termdate <= CURDATE())                                AS total_exits,
       ROUND(100 * SUM(termdate <= CURDATE()) / COUNT(*), 2)     AS attrition_pct,
       ROUND(AVG(CASE WHEN termdate IS NULL OR termdate > CURDATE()
                      THEN age END), 1)                          AS avg_age_active
FROM hr_data;


-- #Q12 Top 10 job titles by attrition (50+ employees, so tiny teams don't skew it)
SELECT jobtitle, department,
       COUNT(*)                                              AS total,
       ROUND(100 * SUM(termdate <= CURDATE()) / COUNT(*), 2) AS attrition_pct
FROM hr_data
GROUP BY jobtitle, department
HAVING COUNT(*) >= 50
ORDER BY attrition_pct DESC
LIMIT 10;


-- #Q13 When do people leave? Exits by tenure band, with share of all exits
SELECT CASE
         WHEN DATEDIFF(termdate, hire_date) < 365      THEN '1. < 1 yr'
         WHEN DATEDIFF(termdate, hire_date) < 3 * 365  THEN '2. 1-3 yrs'
         WHEN DATEDIFF(termdate, hire_date) < 5 * 365  THEN '3. 3-5 yrs'
         WHEN DATEDIFF(termdate, hire_date) < 10 * 365 THEN '4. 5-10 yrs'
         ELSE '5. 10+ yrs'
       END AS tenure_at_exit,
       COUNT(*) AS exits,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_exits
FROM hr_data
WHERE termdate <= CURDATE()
GROUP BY tenure_at_exit
ORDER BY tenure_at_exit;


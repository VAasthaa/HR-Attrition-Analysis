CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

DROP TABLE IF EXISTS hr;
CREATE TABLE hr(
  id              VARCHAR(20),
  first_name      VARCHAR(50),
  last_name       VARCHAR(50),
  birthdate       VARCHAR(20),
  gender          VARCHAR(30),
  race            VARCHAR(60),
  department      VARCHAR(60),
  jobtitle        VARCHAR(100),
  location        VARCHAR(30),
  hire_date       VARCHAR(20),
  termdate        VARCHAR(30),
  location_city   VARCHAR(60),
  location_state  VARCHAR(60)
);


LOAD DATA LOCAL INFILE 'Human Resources.csv'
INTO TABLE hr
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) AS raw_rows FROM hr;    
SELECT * FROM hr LIMIT 5;                

SET SESSION sql_mode = '';
DROP TABLE IF EXISTS hr_data;
CREATE TABLE hr_data AS
SELECT
  emp_id, first_name, last_name,
  CASE WHEN birth_parsed > CURDATE()
       THEN DATE_SUB(birth_parsed, INTERVAL 100 YEAR)
       ELSE birth_parsed END                                  AS birthdate,
  gender, race, department, jobtitle, location,
  hire_date, termdate, location_city, location_state,
  TIMESTAMPDIFF(YEAR,
       CASE WHEN birth_parsed > CURDATE()
            THEN DATE_SUB(birth_parsed, INTERVAL 100 YEAR)
            ELSE birth_parsed END,
       CURDATE())  AS age
FROM (
  SELECT
    TRIM(id) AS emp_id,
    first_name, last_name, gender, race, department, jobtitle, location,
	CASE
      WHEN birthdate LIKE '%/%'THEN STR_TO_DATE(birthdate, '%m/%d/%Y')
      WHEN birthdate REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$' THEN STR_TO_DATE(birthdate, '%m-%d-%Y')
      WHEN birthdate REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$' THEN STR_TO_DATE(birthdate, '%m-%d-%y')
    END AS birth_parsed,

	CASE
      WHEN hire_date LIKE '%/%'THEN STR_TO_DATE(hire_date, '%m/%d/%Y')
      WHEN hire_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$' THEN STR_TO_DATE(hire_date, '%m-%d-%Y')
      WHEN hire_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$' THEN STR_TO_DATE(hire_date, '%m-%d-%y')
    END AS hire_date,
    CASE
      WHEN TRIM(termdate) = '' THEN NULL
      ELSE DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
    END                                                       AS termdate,
    location_city,
    TRIM(TRAILING '\r' FROM location_state)                   AS location_state
  FROM hr
) AS parsed;



SELECT COUNT(*)                          AS total_rows,         
       MIN(age) AS youngest, MAX(age) AS oldest,                
       SUM(age < 18)                     AS under_18,            
       SUM(birthdate IS NULL)            AS null_birthdates,     
       SUM(hire_date IS NULL)            AS null_hire_dates,     
       SUM(termdate < hire_date)         AS exit_before_hire,    
       COUNT(*) - COUNT(DISTINCT emp_id) AS duplicate_ids,       
       MIN(hire_date) AS first_hire, MAX(hire_date) AS last_hire 
FROM hr_data;

SELECT SUM(TIMESTAMPDIFF(YEAR, birthdate, hire_date) < 18) AS hired_under_18,
       SUM(hire_date < birthdate)                          AS hired_before_birth
FROM hr_data;

SELECT location_state, COUNT(*) FROM hr_data GROUP BY location_state;




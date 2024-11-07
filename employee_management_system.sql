CREATE TABLE emp_data
(	id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

DROP TABLE IF EXISTS emp_data;

CREATE TABLE emp_data (
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    gender VARCHAR(15)
);

ALTER TABLE emp_data
ADD COLUMN date_of_birth DATE,
ADD COLUMN hire_date DATE,
ADD COLUMN job_title VARCHAR(100),
ADD COLUMN department_id INTEGER;


CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample departments
INSERT INTO departments (department_id, department_name, location) VALUES
(1, 'Human Resources', 'Floor 1'),
(2, 'Engineering', 'Floor 2'),
(3, 'Sales', 'Floor 3'),
(4, 'Marketing', 'Floor 2'),
(5, 'Finance', 'Floor 1');


CREATE TABLE salaries (
    salary_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES emp_data(id),
    amount DECIMAL(10,2),
    effective_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES emp_data(id),
    date DATE,
    clock_in TIME,
    clock_out TIME,
    status VARCHAR(20) CHECK (status IN ('Present', 'Absent', 'Late', 'Half-day')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leaves (
    leave_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES emp_data(id),
    leave_type VARCHAR(20) CHECK (leave_type IN ('Sick', 'Vacation', 'Unpaid', 'Personal')),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payroll (
    payroll_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES emp_data(id),
    salary_amount DECIMAL(10,2),
    bonus DECIMAL(10,2),
    deductions DECIMAL(10,2),
    net_pay DECIMAL(10,2),
    pay_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update existing emp_data records with random values for new columns
UPDATE emp_data
SET 
    date_of_birth = TIMESTAMP '1970-01-01' + 
                    (random() * (TIMESTAMP '2000-12-31' - TIMESTAMP '1970-01-01')),
    hire_date = TIMESTAMP '2015-01-01' +
                (random() * (TIMESTAMP '2023-12-31' - TIMESTAMP '2015-01-01')),
    job_title = (
        CASE (random() * 4)::INT
            WHEN 0 THEN 'Software Engineer'
            WHEN 1 THEN 'Data Analyst'
            WHEN 2 THEN 'Project Manager'
            WHEN 3 THEN 'Business Analyst'
            WHEN 4 THEN 'Product Manager'
        END
    ),
    department_id = (random() * 4 + 1)::INT;

INSERT INTO salaries (employee_id, amount, effective_date, end_date)
SELECT 
    id as employee_id,
    CASE 
        WHEN job_title = 'Software Engineer' THEN random() * (150000 - 80000) + 80000
        WHEN job_title = 'Data Analyst' THEN random() * (120000 - 60000) + 60000
        WHEN job_title = 'Project Manager' THEN random() * (130000 - 90000) + 90000
        WHEN job_title = 'Business Analyst' THEN random() * (110000 - 70000) + 70000
        ELSE random() * (140000 - 85000) + 85000
    END as amount,
    hire_date as effective_date,
    NULL as end_date
FROM emp_data;

WITH RECURSIVE dates AS (
    SELECT CURRENT_DATE - INTERVAL '30 days' AS date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM dates
    WHERE date < CURRENT_DATE
)
INSERT INTO attendance (employee_id, date, clock_in, clock_out, status)
SELECT 
    e.id,
    d.date,
    CASE 
        WHEN random() < 0.1 THEN NULL  -- 10% chance of absence
        ELSE '09:00:00'::TIME + (random() * INTERVAL '30 minutes')
    END as clock_in,
    CASE 
        WHEN random() < 0.1 THEN NULL  -- 10% chance of absence
        ELSE '17:00:00'::TIME + (random() * INTERVAL '60 minutes')
    END as clock_out,
    CASE 
        WHEN random() < 0.1 THEN 'Absent'
        WHEN random() < 0.2 THEN 'Late'
        ELSE 'Present'
    END as status
FROM emp_data e
CROSS JOIN dates d
WHERE d.date <= CURRENT_DATE;


-- Generate some leave records for each employee
INSERT INTO leaves (employee_id, leave_type, start_date, end_date, status)
SELECT 
    id as employee_id,
    CASE (random() * 3)::INT
        WHEN 0 THEN 'Sick'
        WHEN 1 THEN 'Vacation'
        WHEN 2 THEN 'Personal'
        WHEN 3 THEN 'Unpaid'
    END as leave_type,
    CURRENT_DATE - (random() * 60)::INT as start_date,
    CURRENT_DATE - (random() * 30)::INT as end_date,
    CASE (random() * 2)::INT
        WHEN 0 THEN 'Approved'
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Rejected'
    END as status
FROM emp_data
CROSS JOIN generate_series(1, 3); -- 3 leave records per employee


INSERT INTO payroll (employee_id, salary_amount, bonus, deductions, net_pay, pay_date)
SELECT 
    e.id as employee_id,
    s.amount/12 as salary_amount,
    CASE 
        WHEN random() < 0.3 THEN round((random() * 5000)::numeric, 2)  -- 30% chance of bonus
        ELSE 0
    END as bonus,
    round((s.amount/12 * 0.3)::numeric, 2) as deductions,  -- 30% deductions for tax, insurance etc
    round((s.amount/12 * 0.7)::numeric, 2) as net_pay,     -- Net pay after deductions
    make_date(2024, generate_series, 1) as pay_date        -- Last 3 months
FROM emp_data e
JOIN salaries s ON e.id = s.employee_id
CROSS JOIN generate_series(1, 3);


-- Check employee details with department
SELECT e.*, d.department_name 
FROM emp_data e 
JOIN departments d ON e.department_id = d.department_id 
LIMIT 5;

-- Check salary distribution by department
SELECT d.department_name, 
       COUNT(*) as employee_count,
       ROUND(AVG(s.amount)::numeric, 2) as avg_salary
FROM emp_data e
JOIN departments d ON e.department_id = d.department_id
JOIN salaries s ON e.id = s.employee_id
GROUP BY d.department_name;

-- Check attendance statistics
SELECT e.first_name, e.last_name,
       COUNT(CASE WHEN a.status = 'Present' THEN 1 END) as present_days,
       COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) as absent_days,
       COUNT(CASE WHEN a.status = 'Late' THEN 1 END) as late_days
FROM emp_data e
JOIN attendance a ON e.id = a.employee_id
GROUP BY e.id, e.first_name, e.last_name
LIMIT 5;


-- List all departments and their locations
select department_name, location from departments;

-- Get all employee names and their job titles
select first_name,last_name, job_title from emp_data;

-- Find all unique job titles in the company
select distinct job_title from emp_data;

-- Find all employees in the Engineering department
select e.first_name, e.last_name
from emp_data e
join departments d on e.department_id = d.department_id
where department_name = 'Engineering';

-- List employees hired in 2023
select first_name, last_name, hire_date
from emp_data e
where extract( year from hire_date) = 2023;

-- Find all approved leave requests
select e.first_name, e.last_name, l.leave_type, l.start_date, l.end_date
from emp_data e
join leaves l on e.id = l.employee_id
where l.status = 'Approved';

--  Calculate average attendance rate by department
select d.department_name, round(count(case when a.status = 'Present' Then 1 end)*100/count(*),2
) as attendance_rate_percentage
from emp_data e
join departments d on e.department_id = d.department_id
join attendance a on e.id = a.employee_id
group by d.department_name
order by attendance_rate_percentage desc;

--  Find employees who have taken more than 1 sick leaves
select e.first_name, e.last_name, count(*) as sick_leave_count
from emp_data e
join leaves l on e.id = l.employee_id
where l.leave_type = 'Sick'
 		and l.status = 'Approved'
group by e.id, e.first_name, e.last_name
having count(*)>1;

--  Calculate total compensation (salary + bonus - deductions) 
-- for each employee in the last 3 months
select e.first_name, e.last_name , round(sum(p.salary_amount + p.bonus - p.deductions), 2) as total_compensation
from emp_data e
join payroll p on e.id = p.employee_id
group by e.id, e.first_name, e.last_name
order by total_compensation desc;

--  Find employees who are frequently late 
-- (more than 20% of their attendance records)
with employee_attendance as (
select e.id, e.first_name, e.last_name, count(case when a.status = 'Late' then 1 end) as late_days, count(*) as total_days
from emp_data e
join attendance a on e.id = a.employee_id
group by e.id, e.first_name, e.last_name
)
select first_name,
    last_name,
    late_days,
    total_days,
	round((late_days *100/total_days), 2) as late_percentage
	FROM employee_attendance
WHERE (late_days * 100.0 / total_days) > 20
ORDER BY late_percentage DESC;
	
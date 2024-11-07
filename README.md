# Employee Management System

The Employee Management System is a comprehensive database-driven application designed to streamline HR and payroll operations for a company. This project includes a PostgreSQL database schema, sample data, and SQL queries to manage employee information, attendance, leaves, salaries, and payroll.

## Features

The system supports the following key features:

1. **Employee Data Management**:
   - Store employee details like name, email, gender, date of birth, hire date, job title, and department.
   - Easily retrieve and update employee information.

2. **Department Management**:
   - Maintain a database of company departments, including the department name, location, and manager.
   - Associate employees with their respective departments.

3. **Attendance Tracking**:
   - Record employee clock-in and clock-out times.
   - Track attendance status (present, absent, late, half-day).
   - Generate attendance reports and statistics.

4. **Leave Management**:
   - Allow employees to request different types of leaves (sick, vacation, unpaid, personal).
   - Manage the approval and rejection of leave requests.
   - Monitor employee leave history and balances.

5. **Salary and Payroll Management**:
   - Store employee salary details, including the salary amount, effective date, and end date.
   - Calculate and store employee net pay, including salary, bonuses, and deductions.
   - Produce payroll reports for a given period.

6. **Reporting and Analytics**:
   - Generate reports on employee attendance, leave usage, salary distribution, and compensation.
   - Analyze data to identify trends, such as frequent latecomers or employees with multiple sick leaves.

## Getting Started

To set up the Employee Management System, follow these steps:

1. Create a new PostgreSQL database.
2. Run the SQL script `employee_management_system.sql` to create the necessary tables and populate the sample data.
3. Explore the sample SQL queries provided in the script to understand how to interact with the database.
4. Integrate the database schema into your application's backend to provide a user-friendly interface for managing employee data, attendance, leaves, and payroll.


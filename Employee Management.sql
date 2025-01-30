-- Creating Database
CREATE DATABASE IF NOT EXISTS employee_management;
USE employee_management;

-- Creating Tables
CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    department_id INT,
    job_title VARCHAR(50) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS performance_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    review_date DATE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- Inserting Data
INSERT INTO departments (department_name, location) VALUES
    ('Sales', 'New York'),
    ('HR', 'Los Angeles'),
    ('IT', 'San Francisco')
ON DUPLICATE KEY UPDATE location = VALUES(location);

INSERT INTO employees (first_name, last_name, email, hire_date, salary, department_id, job_title) VALUES
    ('Maurine', 'Nyongesa', 'maurine.nyongesa@gmail.com', '2021-03-15', 55000, 1, 'Sales Executive'),
    ('Asa', 'Moh', 'asa.moh@gmail.com', '2020-06-30', 60000, 2, 'HR Manager'),
    ('Steve', 'Jobs', 'steve.jobs@gmail.com', '2019-08-10', 75000, 3, 'IT Specialist'),
    ('Jane', 'Doe', 'jane.doe@email.com', '2023-05-15', 55000, 2, 'Marketing Specialist')
ON DUPLICATE KEY UPDATE salary = VALUES(salary);

INSERT INTO performance_reviews (employee_id, review_date, rating, comments) VALUES
    (1, '2023-06-15', 4, 'Great performance but needs improvement in client interaction.'),
    (2, '2023-05-12', 5, 'Excellent management skills highly recommended for promotion.'),
    (3, '2023-07-20', 3, 'Satisfactory performance but needs more technical training.')
ON DUPLICATE KEY UPDATE rating = VALUES(rating), comments = VALUES(comments);

-- Queries

-- Retrieve All Employees with Their Department Names
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Find Employees with a Salary Above 60,000
SELECT first_name, last_name
FROM employees
WHERE salary > 60000;

-- Get Performance Reviews for a Specific Employee
SELECT e.first_name, e.last_name, p.review_date, p.rating, p.comments
FROM employees e
JOIN performance_reviews p ON e.employee_id = p.employee_id
WHERE e.employee_id = 1;

-- Average Salary by Department
SELECT d.department_name, AVG(e.salary) AS average_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- Employees with the Highest Ratings
SELECT e.first_name, e.last_name, p.rating
FROM employees e
JOIN performance_reviews p ON e.employee_id = p.employee_id
WHERE p.rating = 5;

-- Ranking Employees by Salary
SELECT first_name, last_name, salary,
       RANK() OVER(ORDER BY salary DESC) AS salary_rank
FROM employees;

-- Cumulative Salary for Employees
SELECT first_name, last_name, salary,
       SUM(salary) OVER (ORDER BY salary DESC) AS cumulative_salary
FROM employees
ORDER BY salary DESC;

-- Average Salary Per Department per Employee
SELECT first_name, last_name, department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS avg_department_salary
FROM employees;

-- Row Number Based on Hire Date
SELECT first_name, last_name, hire_date,
       ROW_NUMBER() OVER (ORDER BY hire_date ASC) AS row_num
FROM employees;

-- Lead and Lag Functions for Performance Reviews
SELECT employee_id, review_date, rating,
       LAG(rating) OVER (PARTITION BY employee_id ORDER BY review_date) AS prev_rating,
       LEAD(rating) OVER (PARTITION BY employee_id ORDER BY review_date) AS next_rating
FROM performance_reviews;

-- Percent Rank for Salaries
SELECT first_name, last_name, salary,
       PERCENT_RANK() OVER (ORDER BY salary DESC) AS percent_rank_salary
FROM employees;

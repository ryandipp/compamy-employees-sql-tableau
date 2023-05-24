-- Male:Female Employees over the year 1990-2002
SELECT 
    YEAR(de.from_date) year_,
    e.gender gender_,
    COUNT(de.emp_no) emp_qty
FROM
    t_dept_emp de
        JOIN
    t_employees e ON de.emp_no = e.emp_no
WHERE
    YEAR(e.hire_date) BETWEEN 1990 AND 2002
        AND YEAR(de.from_date) BETWEEN 1990 AND 2002
GROUP BY YEAR(de.from_date) , e.gender
ORDER BY YEAR(de.from_date);

;
-- AVG SALARY MALE:FEMALE EACH DEPT EACH YEAR
SELECT 
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary), 2) salary_,
    YEAR(s.from_date) cal_year
FROM
    t_salaries s
        JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
        JOIN
    t_employees e ON e.emp_no = de.emp_no
GROUP BY d.dept_name , e.gender , cal_year
HAVING cal_year <= 2002
ORDER BY dept_name , gender , cal_year;

-- ACTIVE MALE:FEMALE MANAGERS YEARLY ON INDIVIDUAL
SELECT 
    d.dept_name,
    e.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    ey.cal_year,
    CASE
        WHEN
            YEAR(from_date) <= cal_year
                AND YEAR(to_date) >= cal_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) cal_year
    FROM
        t_employees
    WHERE
        YEAR(hire_date) >= 1990
    GROUP BY cal_year) ey
        JOIN
    t_dept_manager dm ON 1 = 1
        JOIN
    t_employees e ON dm.emp_no = e.emp_no
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
ORDER BY emp_no , cal_year;

-- VIA PROCEDURE: AVG SALARY MALE:FEMALE OVERALL EACH DEPT
DROP PROCEDURE IF EXISTS m_f_avgsal_dept;
DELIMITER $$
CREATE PROCEDURE m_f_avgsal_dept()
BEGIN
    SELECT d.dept_name,
           e.gender,
           ROUND(AVG(s.salary), 2) AS salary_
    FROM t_salaries s
    JOIN t_dept_emp de ON s.emp_no = de.emp_no
    JOIN t_departments d ON d.dept_no = de.dept_no
    JOIN t_employees e ON e.emp_no = de.emp_no
    GROUP BY d.dept_name, e.gender
    ORDER BY dept_name, gender;
END$$
DELIMITER ;

CALL m_f_avgsal_dept();


-- BONUS: MEDIAN SALARY    
WITH t2 AS (
    SELECT ROW_NUMBER() OVER (ORDER BY t1.salary) AS rownum,
           COUNT(*) OVER () AS total_rows,
           t1.emp_no,
           t1.salary
    FROM (
        SELECT emp_no, MAX(salary) AS salary
        FROM t_salaries
        GROUP BY emp_no
    ) AS t1
)
SELECT t2.salary
FROM t2
WHERE rownum IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2));
        
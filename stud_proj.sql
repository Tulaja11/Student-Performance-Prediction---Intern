-- ============================================================
--   STUDENT PERFORMANCE ANALYSIS — SQL PROJECT
--   Database : stud_performance
--   Table    : student_performance
-- ============================================================

USE stud_performance;

-- ============================================================
-- SECTION 1 : DATABASE OVERVIEW
-- ============================================================

-- 1.1  Total number of students
SELECT COUNT(*) AS total_students
FROM student_performance;

-- 1.2  Preview first 10 rows
SELECT *
FROM student_performance
LIMIT 10;

-- 1.3  Check all column names and data types
DESCRIBE student_performance;

-- 1.4  Check for NULL values in key columns
SELECT
  SUM(`Final_Score` IS NULL) AS null_final_score,
  SUM(`Attendance (%)` IS NULL) AS null_attendance,
  SUM(`Study_Hours_per_Week` IS NULL) AS null_study_hours,
  SUM(`Pass_Fail` IS NULL) AS null_pass_fail
FROM student_performance;

-- 1.5  Check for duplicate Student IDs
SELECT Student_ID, COUNT(*) AS occurrences
FROM student_performance
GROUP BY Student_ID
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 2 : BASIC STATISTICS
-- ============================================================

-- 2.1  Summary statistics for key numeric columns
SELECT
  ROUND(AVG(`Final_Score`), 2) AS avg_final_score,
  ROUND(MIN(`Final_Score`), 2) AS min_final_score,
  ROUND(MAX(`Final_Score`), 2) AS max_final_score,
  ROUND(STDDEV_POP(`Final_Score`), 2) AS std_final_score,
  ROUND(AVG(`Attendance (%)`), 2) AS avg_attendance,
  ROUND(AVG(`Study_Hours_per_Week`), 2) AS avg_study_hours
FROM student_performance;

-- 2.2  Grade distribution (how many students per grade)
SELECT
    Grade,
    COUNT(*)                                    AS total_students,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM student_performance
GROUP BY Grade
ORDER BY FIELD(Grade, 'A', 'B', 'C', 'D', 'F');

-- 2.3  Pass vs Fail count
SELECT
    Pass_Fail,
    CASE WHEN Pass_Fail = 1 THEN 'Pass' ELSE 'Fail' END AS result,
    COUNT(*)                                             AS total_students,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)   AS percentage
FROM student_performance
GROUP BY Pass_Fail;

-- 2.4  Department-wise student count
SELECT
    Department,
    COUNT(*) AS total_students
FROM student_performance
GROUP BY Department
ORDER BY total_students DESC;


-- ============================================================
-- SECTION 3 : EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================================

-- 3.1  Average Final Score by Grade
SELECT
    Grade,
    COUNT(*)                          AS students,
    ROUND(AVG(Final_Score),       2)  AS avg_final_score,
    ROUND(AVG(Midterm_Score),     2)  AS avg_midterm,
    ROUND(AVG(Study_Hours_per_Week),2) AS avg_study_hours,
    ROUND(AVG(`Attendance (%)`),  2)  AS avg_attendance
FROM student_performance
GROUP BY Grade
ORDER BY FIELD(Grade, 'A', 'B', 'C', 'D', 'F');

-- 3.2  Average Final Score by Gender
SELECT
    Gender,
    COUNT(*)                         AS students,
    ROUND(AVG(Final_Score),      2)  AS avg_final_score,
    ROUND(AVG(`Attendance (%)`), 2)  AS avg_attendance
FROM student_performance
GROUP BY Gender;

-- 3.3  Impact of Internet Access on Final Score
SELECT
    Internet_Access_at_Home,
    COUNT(*)                         AS students,
    ROUND(AVG(Final_Score),      2)  AS avg_final_score,
    ROUND(AVG(Study_Hours_per_Week), 2) AS avg_study_hours
FROM student_performance
GROUP BY Internet_Access_at_Home;

-- 3.4  Impact of Extracurricular Activities on Final Score
SELECT
    Extracurricular_Activities,
    COUNT(*)                         AS students,
    ROUND(AVG(Final_Score),      2)  AS avg_final_score,
    ROUND(AVG(Study_Hours_per_Week), 2) AS avg_study_hours
FROM student_performance
GROUP BY Extracurricular_Activities;

-- 3.5  Family Income Level vs Performance
SELECT
    Family_Income_Level,
    COUNT(*)                         AS students,
    ROUND(AVG(Final_Score),      2)  AS avg_final_score,
    ROUND(AVG(`Attendance (%)`), 2)  AS avg_attendance
FROM student_performance
GROUP BY Family_Income_Level
ORDER BY avg_final_score DESC;

-- 3.6  Parent Education Level vs Student Performance
SELECT
    Parent_Education_Level,
    COUNT(*)                         AS students,
    ROUND(AVG(Final_Score),      2)  AS avg_final_score,
    ROUND(AVG(Study_Hours_per_Week), 2) AS avg_study_hours
FROM student_performance
GROUP BY Parent_Education_Level
ORDER BY avg_final_score DESC;

-- 3.7  Stress Level vs Final Score
SELECT
    `Stress_Level (1-10)` AS stress_level,
    COUNT(*)              AS students,
    ROUND(AVG(Final_Score), 2) AS avg_final_score
FROM student_performance
GROUP BY `Stress_Level (1-10)`
ORDER BY `Stress_Level (1-10)`;


-- ============================================================
-- SECTION 4 : ATTENDANCE BAND ANALYSIS
-- (Key insight: Does attendance bracket predict performance?)
-- ============================================================

-- 4.1  Score by Attendance Band
SELECT
    CASE
        WHEN `Attendance (%)` >= 90 THEN '90-100% (Excellent)'
        WHEN `Attendance (%)` >= 75 THEN '75-89%  (Good)'
        WHEN `Attendance (%)` >= 60 THEN '60-74%  (Average)'
        ELSE                              'Below 60% (Poor)'
    END                                   AS attendance_band,
    COUNT(*)                              AS students,
    ROUND(AVG(Final_Score),           2)  AS avg_final_score,
    ROUND(AVG(Study_Hours_per_Week),  2)  AS avg_study_hours,
    SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END) AS fail_count,
    ROUND(
        SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                     AS fail_rate_pct
FROM student_performance
GROUP BY attendance_band
ORDER BY avg_final_score DESC;

-- 4.2  Students with low attendance who are at risk of failing
SELECT
    Student_ID,
    CONCAT(First_Name, ' ', Last_Name)  AS student_name,
    Department,
    ROUND(`Attendance (%)`,          2) AS attendance_pct,
    ROUND(Study_Hours_per_Week,      2) AS study_hours,
    ROUND(Final_Score,               2) AS final_score,
    Grade,
    Pass_Fail
FROM student_performance
WHERE `Attendance (%)` < 70
  AND Pass_Fail = 0
ORDER BY Final_Score ASC
LIMIT 20;


-- ============================================================
-- SECTION 5 : STUDY HOURS BAND ANALYSIS
-- ============================================================

-- 5.1  Score by Study Hours Band
SELECT
    CASE
        WHEN Study_Hours_per_Week >= 20 THEN '20+ hrs (High)'
        WHEN Study_Hours_per_Week >= 15 THEN '15-19 hrs (Above Avg)'
        WHEN Study_Hours_per_Week >= 10 THEN '10-14 hrs (Average)'
        ELSE                                 'Below 10 hrs (Low)'
    END                                  AS study_band,
    COUNT(*)                             AS students,
    ROUND(AVG(Final_Score),          2)  AS avg_final_score,
    ROUND(AVG(`Attendance (%)`),     2)  AS avg_attendance,
    SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END) AS fail_count,
    ROUND(
        SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                    AS fail_rate_pct
FROM student_performance
GROUP BY study_band
ORDER BY avg_final_score DESC;


-- ============================================================
-- SECTION 6 : AT-RISK STUDENT IDENTIFICATION
-- ============================================================

-- 6.1  High-risk students (low attendance AND low study hours AND failing)
SELECT
    Student_ID,
    CONCAT(First_Name, ' ', Last_Name) AS student_name,
    Department,
    Grade,
    ROUND(`Attendance (%)`,          2) AS attendance_pct,
    ROUND(Study_Hours_per_Week,      2) AS study_hours,
    ROUND(Final_Score,               2) AS final_score,
    `Stress_Level (1-10)`               AS stress_level
FROM student_performance
WHERE `Attendance (%)` < 70
  AND Study_Hours_per_Week < 10
  AND Pass_Fail = 0
ORDER BY Final_Score ASC;

-- 6.2  Count of at-risk students by Department
SELECT
    Department,
    COUNT(*) AS at_risk_students,
    ROUND(AVG(Final_Score), 2) AS avg_score_of_atrisk
FROM student_performance
WHERE `Attendance (%)` < 70
  AND Study_Hours_per_Week < 10
  AND Pass_Fail = 0
GROUP BY Department
ORDER BY at_risk_students DESC;


-- ============================================================
-- SECTION 7 : SCORE COMPONENT ANALYSIS
-- (Midterm, Assignments, Quizzes, Projects → Final Score)
-- ============================================================

-- 7.1  Average of each score component by Grade
SELECT
    Grade,
    ROUND(AVG(Midterm_Score),       2) AS avg_midterm,
    ROUND(AVG(Assignments_Avg),     2) AS avg_assignments,
    ROUND(AVG(Quizzes_Avg),         2) AS avg_quizzes,
    ROUND(AVG(Participation_Score), 2) AS avg_participation,
    ROUND(AVG(Projects_Score),      2) AS avg_projects,
    ROUND(AVG(Final_Score),         2) AS avg_final_score
FROM student_performance
GROUP BY Grade
ORDER BY FIELD(Grade, 'A', 'B', 'C', 'D', 'F');

-- 7.2  Which component has the highest average across all students?
SELECT
    ROUND(AVG(Midterm_Score),       2) AS avg_midterm,
    ROUND(AVG(Assignments_Avg),     2) AS avg_assignments,
    ROUND(AVG(Quizzes_Avg),         2) AS avg_quizzes,
    ROUND(AVG(Participation_Score), 2) AS avg_participation,
    ROUND(AVG(Projects_Score),      2) AS avg_projects
FROM student_performance;


-- ============================================================
-- SECTION 8 : TOP & BOTTOM PERFORMERS
-- ============================================================

-- 8.1  Top 10 students by Final Score
SELECT
    Student_ID,
    CONCAT(First_Name, ' ', Last_Name) AS student_name,
    Department,
    Grade,
    ROUND(Final_Score,               2) AS final_score,
    ROUND(`Attendance (%)`,          2) AS attendance_pct,
    ROUND(Study_Hours_per_Week,      2) AS study_hours
FROM student_performance
ORDER BY Final_Score DESC
LIMIT 10;

-- 8.2  Bottom 10 students by Final Score
SELECT
    Student_ID,
    CONCAT(First_Name, ' ', Last_Name) AS student_name,
    Department,
    Grade,
    ROUND(Final_Score,               2) AS final_score,
    ROUND(`Attendance (%)`,          2) AS attendance_pct,
    ROUND(Study_Hours_per_Week,      2) AS study_hours
FROM student_performance
ORDER BY Final_Score ASC
LIMIT 10;

-- ============================================================
-- SECTION 9 : SLEEP & STRESS ANALYSIS
-- ============================================================

-- 9.1 High stress students and their performance
SELECT
    CASE
        WHEN `Stress_Level (1-10)` >= 8 THEN 'High Stress (8-10)'
        WHEN `Stress_Level (1-10)` >= 5 THEN 'Medium Stress (5-7)'
        ELSE                                  'Low Stress (1-4)'
    END                                  AS stress_band,
    COUNT(*)                             AS students,
    ROUND(AVG(Final_Score),          2)  AS avg_final_score,
    ROUND(AVG(`Attendance (%)`),     2)  AS avg_attendance,
    SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END) AS fail_count
FROM student_performance
GROUP BY stress_band
ORDER BY avg_final_score DESC;


-- ============================================================
-- SECTION 10 : FINAL SUMMARY / DASHBOARD VIEW
-- ============================================================

-- 10.1  Complete summary for reporting / dashboard
SELECT
    COUNT(*)                                                          AS total_students,
    ROUND(AVG(Final_Score),                                       2)  AS overall_avg_score,
    ROUND(AVG(`Attendance (%)`),                                  2)  AS overall_avg_attendance,
    ROUND(AVG(Study_Hours_per_Week),                              2)  AS overall_avg_study_hours,
    SUM(CASE WHEN Pass_Fail = 1 THEN 1 ELSE 0 END)                    AS total_pass,
    SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END)                    AS total_fail,
    ROUND(SUM(CASE WHEN Pass_Fail = 1 THEN 1 ELSE 0 END) * 100.0
          / COUNT(*),                                             2)   AS pass_rate_pct,
    SUM(CASE WHEN `Attendance (%)` < 70 THEN 1 ELSE 0 END)            AS low_attendance_students,
    SUM(CASE WHEN Study_Hours_per_Week < 10 THEN 1 ELSE 0 END)        AS low_study_hour_students,
    SUM(CASE WHEN Grade = 'A' THEN 1 ELSE 0 END)                      AS grade_A_count,
    SUM(CASE WHEN Grade = 'F' THEN 1 ELSE 0 END)                      AS grade_F_count
FROM student_performance;

-- 10.2  Department-wise pass rate (great for a bar chart in your dashboard)
SELECT
    Department,
    COUNT(*)                                                         AS total_students,
    SUM(CASE WHEN Pass_Fail = 1 THEN 1 ELSE 0 END)                   AS passed,
    SUM(CASE WHEN Pass_Fail = 0 THEN 1 ELSE 0 END)                   AS failed,
    ROUND(SUM(CASE WHEN Pass_Fail = 1 THEN 1 ELSE 0 END) * 100.0
          / COUNT(*),                                            2)   AS pass_rate_pct,
    ROUND(AVG(Final_Score),                                      2)   AS avg_score
FROM student_performance
GROUP BY Department
ORDER BY pass_rate_pct DESC;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================

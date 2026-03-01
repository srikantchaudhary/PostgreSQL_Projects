select table_name from all_tables where owner = 'HR';



-- Project: Student Management System 


-- Students Table
CREATE TABLE STUDENTS(
STUDENT_ID NUMBER PRIMARY KEY,
NAME VARCHAR2(100),
EMAIL VARCHAR2(100),
COURSE VARCHAR2(100),
MARKS NUMBER,
GRADE VARCHAR2(2)
);


-- Create Sequence (Auto Increment)

CREATE SEQUENCE STUDENT_SEQ 
START WITH 1 
INCREMENT BY 1;


-- Trigger Auto ID Generator

CREATE OR REPLACE TRIGGER student_trigger
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
   :NEW.student_id := student_seq.NEXTVAL;
END;
/



-- Procedure to insert new record

CREATE OR REPLACE PROCEDURE add_student (
    p_name   VARCHAR2,
    p_email  VARCHAR2,
    p_course VARCHAR2,
    p_marks  NUMBER
)
IS
    v_grade VARCHAR2(2);
BEGIN
    -- Grade Calculation
    IF p_marks >= 90 THEN
        v_grade := 'A+';
    ELSIF p_marks >= 75 THEN
        v_grade := 'A';
    ELSIF p_marks >= 60 THEN
        v_grade := 'B';
    ELSE
        v_grade := 'C';
    END IF;

    INSERT INTO students(name, email, course, marks, grade)
    VALUES(p_name, p_email, p_course, p_marks, v_grade);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Student Added Successfully');
END;
/
    



--  Create Function (Get Grade)

CREATE OR REPLACE FUNCTION get_grade(p_marks NUMBER)
RETURN VARCHAR2
IS
    v_grade VARCHAR2(2);
BEGIN
    IF p_marks >= 90 THEN
        v_grade := 'A+';
    ELSIF p_marks >= 75 THEN
        v_grade := 'A';
    ELSIF p_marks >= 60 THEN
        v_grade := 'B';
    ELSE
        v_grade := 'C';
    END IF;

    RETURN v_grade;
END;
/



--  Create Package


CREATE OR REPLACE PACKAGE student_pkg AS
    PROCEDURE add_student(
        p_name   VARCHAR2,
        p_email  VARCHAR2,
        p_course VARCHAR2,
        p_marks  NUMBER
    );

    PROCEDURE show_students;
END student_pkg;
/



CREATE OR REPLACE PACKAGE BODY student_pkg AS

    PROCEDURE add_student(
        p_name   VARCHAR2,
        p_email  VARCHAR2,
        p_course VARCHAR2,
        p_marks  NUMBER
    )
    IS
        v_grade VARCHAR2(2);
    BEGIN
        v_grade := get_grade(p_marks);

        INSERT INTO students(name, email, course, marks, grade)
        VALUES(p_name, p_email, p_course, p_marks, v_grade);

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Student Added');
    END;

    PROCEDURE show_students IS
    BEGIN
        FOR rec IN (SELECT * FROM students) LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.student_id || ' ' ||
                rec.name || ' ' ||
                rec.course || ' ' ||
                rec.marks || ' ' ||
                rec.grade
            );
        END LOOP;
    END;

END student_pkg;
/



set serveroutput on; 
BEGIN
   student_pkg.show_students;
END;
/
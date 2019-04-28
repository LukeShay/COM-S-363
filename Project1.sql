DROP TABLE Person;
DROP TABLE Student;
DROP TABLE Instructor;
DROP TABLE Enrollment;
DROP TABLE Course;
DROP TABLE Offering;

CREATE TABLE Person (
Name CHAR (20),
ID CHAR (9) NOT NULL,
Address CHAR (30),
DOB DATE,
PRIMARY KEY (ID));

CREATE TABLE Instructor (
InstructorID CHAR (9) NOT NULL REFERENCES Person (ID),
Rank CHAR (12),
Salary INT,
PRIMARY KEY (InstructorID));

CREATE TABLE Student (
StudentID CHAR (9) NOT NULL,
Classification CHAR (10),
GPA DOUBLE,
MentorID CHAR (9) REFERENCES Instructor (InstructorID),
CreditHours INT);

CREATE TABLE Course (
CourseCode CHAR (6) NOT NULL,
CourseName CHAR (50),
PreReq CHAR (6),
PRIMARY KEY (CourseCode, PreReq));

CREATE TABLE Offering (
CourseCode CHAR (6),
SectionNo INT,
InstructorID CHAR(9) REFERENCES Instructor (InstructorID),
PRIMARY KEY (CourseCode, SectionNo));

CREATE TABLE Enrollment (
CourseCode CHAR(6) NOT NULL, 
SectionNo INT NOT NULL, 
StudentID CHAR(9) NOT NULL REFERENCES Student, 
Grade CHAR(4) NOT NULL, 
PRIMARY KEY (CourseCode, StudentID), 
FOREIGN KEY (CourseCode, SectionNo) REFERENCES Offering(CourseCode, SectionNo));

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/Instructor.xml'
INTO TABLE Instructor 
ROWS IDENTIFIED BY '<Instructor>';

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/student.xml'
INTO TABLE Student 
ROWS IDENTIFIED BY '<Student>';

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/course.xml'
INTO TABLE Course 
ROWS IDENTIFIED BY '<Course>';

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/offering.xml'
INTO TABLE Offering 
ROWS IDENTIFIED BY '<Offering>';

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/enrollment.xml'
INTO TABLE Enrollment 
ROWS IDENTIFIED BY '<Enrollment>';

LOAD XML LOCAL INFILE '/Users/luke/documents/github/COM-S-363/UniversityXML/person.xml'
INTO TABLE Person 
ROWS IDENTIFIED BY '<Person>';

#Item 13
SELECT StudentID, MentorID
FROM Student
WHERE Classification = "Junior" OR Classification = "Senior" AND GPA > 3.8;

#Item 14
SELECT DISTINCT Enrollment.CourseCode, Enrollment.SectionNo
FROM Enrollment
INNER JOIN Student ON Enrollment.StudentID = Student.StudentID
WHERE Student.Classification = "Sophomore";

#Item 15
SELECT Person.Name, Instructor.Salary
FROM Person, Instructor, Student
WHERE ID = InstructorID AND Classification = "Freshman" AND InstructorID = MentorID;

#Item 16
SELECT SUM(Salary)
FROM Instructor
WHERE InstructorID NOT IN (SELECT DISTINCT InstructorID FROM Offering);


#Item 17
SELECT DISTINCT Person.Name, Person.DOB
FROM Person, Student
WHERE Person.ID = Student.StudentID AND YEAR(Person.DOB) = 1976;

#Item 18
SELECT DISTINCT Person.Name, Instructor.Rank
FROM Person, Instructor, Student, Offering
WHERE Instructor.InstructorID != Student.MentorID AND Instructor.InstructorID != Offering.InstructorID AND Person.ID = Instructor.InstructorID;

#Item 19
SELECT DISTINCT Person.Name, Person.DOB
FROM Person, Student
WHERE Student.StudentID = Person.ID
ORDER BY Person.DOB DESC
LIMIT 1;

#Item 20
SELECT DISTINCT Person.Name, Person.ID, Person.DOB
FROM Person, Instructor, Student
WHERE Person.ID != Instructor.InstructorID AND Person.ID != Student.StudentID;

#Item 21
SELECT DISTINCT Person.Name, COUNT(Student.StudentID)
FROM Person, Student, Instructor
WHERE Student.MentorID = Instructor.InstructorID AND Person.ID = Instructor.InstructorID
GROUP BY Name;

#Item 22
SELECT Student.Classification, COUNT(Student.StudentID), FORMAT(AVG(Student.GPA), 2)
FROM Student
GROUP BY Student.Classification;

#Item 23
SELECT q3.CourseCode, q3.NumStudents
FROM (SELECT CourseCode, COUNT(StudentID) AS NumStudents
			FROM Enrollment
			GROUP BY CourseCode
			ORDER BY COUNT(StudentID) ASC) q3
WHERE (SELECT MIN(NumStudents) AS least
				FROM (SELECT CourseCode, COUNT(StudentID) AS NumStudents
							FROM Enrollment GROUP BY CourseCode ORDER BY COUNT(StudentID) ASC) q4
				LIMIT 1)  = q3.NumStudents;




#Item 24
SELECT DISTINCT Instructor.InstructorID, Student.StudentID
FROM Instructor, Student, Enrollment, Offering
WHERE Instructor.InstructorID = Offering.InstructorID AND Enrollment.CourseCode = Offering.CourseCode
AND Student.StudentID = Enrollment.StudentID AND Student.MentorID = Instructor.InstructorID;

#Item 25
SELECT Person.Name, Student.StudentID, Student.CreditHours
FROM Student, Person
WHERE Student.StudentID = Person.ID AND YEAR(Person.DOB) >= 1976;

#Item 26
INSERT INTO Student VALUES("480293439", "Junior", 3.48, "201586985", 75);
INSERT INTO Person VALUES("Briggs Jason", "480293439", "215 North Hyland Avenue", DATE '1975-01-15');
INSERT INTO Enrollment VALUES("CS311", 2, "480293439", "A");
INSERT INTO Enrollment VALUES("CS330", 1, "480293439", "A-");

Select *
From Person P
Where P.Name= "Briggs Jason";

Select *
From Student S
Where S.StudentID= "480293439";

Select *
From Enrollment E
Where E.StudentID = "480293439";

#Item 27
DELETE Student, Enrollment FROM Student INNER JOIN Enrollment WHERE gpa < 0.5 AND Enrollment.StudentID = Student.StudentID;

#Item 28
UPDATE Instructor
SET Salary = Salary * 1.10
WHERE (SELECT COUNT(DISTINCT Enrollment.StudentID) FROM Enrollment, Person, Offering
				WHERE Person.Name = "Ricky Ponting" AND Person.ID = Offering.InstructorID AND Offering.CourseCode = Enrollment.CourseCode
								AND Offering.SectionNO = Enrollment.SectionNo AND Enrollment.Grade = "A"
				GROUP BY Enrollment.Grade) >= 4 AND
			   (SELECT ID FROM Person WHERE Name = "Ricky Ponting") = InstructorID;
                                        



#Item 29
INSERT INTO Person VALUES("Trevor Horns", "000957303", "23 Canberra Street", DATE '1964-11-23');

SELECT * FROM Person WHERE Name = "Trevor Horns";


#Item 30
DELETE Student, Enrollment FROM Student INNER JOIN Enrollment INNER JOIN Person WHERE Person.Name = "Jan Austin"
	AND Person.ID =  Enrollment.StudentID AND Person.ID = Student.StudentID;
    
SELECT s.StudentID, s.GPA, s.CreditHours, e.Grade
FROM Student s, Enrollment e
WHERE s.StudentID = e.StudentID 
ORDER BY s.StudentID DESC;
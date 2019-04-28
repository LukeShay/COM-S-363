import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.*;

public class JDBC_Students {

	private static Connection conn1;

	public static void main(String[] args) throws Exception {
		try {
			// Connect to the database
			String dbUrl = "jdbc:mysql://csdb.cs.iastate.edu:3306/db363lshay";
			String user = "dbu363lshay";
			String password = "QtpB5727";
			conn1 = DriverManager.getConnection(dbUrl, user, password);
			System.out.println("*** Connected to the database ***");

			partA();
			System.out.println("*** Part A done ***");
			partB();
			System.out.println("*** Part B done ***");

			conn1.close();

		}
		catch (SQLException e) {
			System.out.println("SQLException: " + e.getMessage());
			System.out.println("SQLState: " + e.getSQLState());
			System.out.println("VendorError: " + e.getErrorCode());
		}
	}

	/**
	 * Recall that the Student relation in the University database shows the
	 * currently values of credit hours and GPA of each student. The Enrollment
	 * table shows the courses that students are currently enrolled in and their
	 * grades in those courses. Pretend now that is the end of the semester, and
	 * the student records need to be updated. For each student, update the
	 * credit hours, classification, and the GPA, taking into account the
	 * current GPA and grades in the courses the student is currently enrolled
	 * in. All the courses are 3 credit courses.
	 * 
	 * @throws FileNotFoundException
	 * @throws UnsupportedEncodingException
	 */

	static void partA()
			throws FileNotFoundException, UnsupportedEncodingException {
		// Create Statement and ResultSet variables to use throughout the
		// project
		Statement statement;
		try {
			// Opens up the file to write the output.
			PrintWriter writer = new PrintWriter("JDBC_StudentsOutput.txt",
					"UTF-8");

			// Creates a statement on the opened connection.
			statement = conn1.createStatement();

			ResultSet rs;

			// Gets student grade,
			rs = statement.executeQuery(
					"SELECT s.StudentID, s.GPA, s.CreditHours, e.Grade "
							+ "FROM Student s, Enrollment e "
							+ "WHERE s.StudentID = e.StudentID "
							+ "ORDER BY s.StudentID DESC");
			String id = "";
			float gpa = 0;
			int hours = 0;
			String grade = "";
			String tempid = "";
			int i = 0;

			PreparedStatement stmt1 = conn1.prepareStatement(
					"UPDATE Student SET GPA=?, CreditHours=? WHERE StudentID = ? ");

			while (rs.next()) {
				tempid = rs.getString("StudentID");
				grade = rs.getString("Grade");

				if (i == 0) {
					id = rs.getString("StudentID");
					gpa = rs.getFloat("GPA");
					hours = rs.getInt("CreditHours");
				}

				if (!tempid.equals(id)) {
					gpa = (float) (Math.round(gpa * 100) / 100.0);
					gpa = gpa > 4 ? 4 : gpa;

					stmt1.setFloat(1, gpa);
					stmt1.setInt(2, hours);
					stmt1.setString(3, id);

					stmt1.executeUpdate();

					String s = String.format(
							"StudentID: %s  GPA: %1.2f  New Hours: %3d", id,
							gpa, hours);

					writer.println(s);

					id = rs.getString("StudentID");
					gpa = rs.getFloat("GPA");
					hours = rs.getInt("CreditHours");

					gpa = (float) (((gpa * hours) + (getGPA(grade) * 3))
							/ (hours + 3));
					hours += 3;

				}
				else {
					gpa = (float) (((gpa * hours) + (getGPA(grade) * 3))
							/ (hours + 3));
					hours += 3;
				}

				i = 1;
			}
			statement.close();
			rs.close();
			writer.close();
		}
		catch (SQLException e) {
			System.out.println("SQLException: " + e.getMessage());
			System.out.println("SQLState: " + e.getSQLState());
			System.out.println("VendorError: " + e.getErrorCode());
		}
	}

	/**
	 * After you have updated the student table, execute an SQL query that
	 * selects names of seniors, names of their mentors, and GPA in descending
	 * order of GPA-values. Then write java code to go through the result set of
	 * the query and print the names of the students, name of their mentors, and
	 * their GPA, for top 5 (or more) seniors. Note that this list may contain
	 * less than 5 distinct GPA-values and more than 5 students. This is because
	 * some students may have the same GPA. After having taken top 5 students
	 * into account, you should include those students who have the same GPA as
	 * the 5th student. The printout must be directed to P3Output.txt file.
	 * 
	 * @throws FileNotFoundException
	 * @throws UnsupportedEncodingException
	 * 
	 */
	static void partB()
			throws FileNotFoundException, UnsupportedEncodingException {
		try {
			Statement statement;

			// Opens up the file to write the output.
			PrintWriter writer = new PrintWriter("P3Output.txt", "UTF-8");

			// Creates a statement on the opened connection.
			statement = conn1.createStatement();

			ResultSet rs;

			String s = "SELECT p.Name, p1.Name, s.GPA " + 
					   "FROM Person p, Person p1, Student s " + 
					   "WHERE p.ID = s.StudentID AND " +
					   "s.Classification = \"Senior\" AND " +
					   "p1.ID = s.MentorID ORDER BY s.GPA DESC";

			rs = statement.executeQuery(s);

			float gpa = 0;
			int numStudents = 0;

			while (rs.next() && (numStudents < 5 || rs.getFloat(3) == gpa)) {
				gpa = rs.getFloat(3);

				s = String.format(
						"Student Name: %15s  MentorName: %15s  GPA: %1.2f",
						rs.getString(1), rs.getString(2), gpa);
				writer.println(s);

				numStudents++;
			}

			statement.close();
			rs.close();
			writer.close();
		}
		catch (SQLException e) {
			System.out.println("SQLException: " + e.getMessage());
			System.out.println("SQLState: " + e.getSQLState());
			System.out.println("VendorError: " + e.getErrorCode());
		}

	}

	static double getGPA(String grade) {
		switch (grade.trim()) {
			case "A":
				return 4.00;

			case "A-":
				return 3.66;

			case "B+":
				return 3.33;

			case "B":
				return 3.00;

			case "B-":
				return 2.66;

			case "C+":
				return 2.33;

			case "C":
				return 2.00;

			case "C-":
				return 1.66;

			case "D+":
				return 1.33;

			case "D":
				return 1.00;

			case "F":
				return 0.00;

			default:
				return 0;
		}
	}
}

require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students(name,grade)
      VALUES(?,?)
      SQL
      DB[:conn].execute(sql,self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
    end
  end

  def self.create(name, breed)
    student = Student.new(name, breed)
    student.save
    student
  end

  def self.new_from_db(row)
  # create a new Student object given a row from the database
    id = row[0]
    name = row[1]
    grade = row[2]
    student = self.new(name, grade, id)
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end

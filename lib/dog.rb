require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  ########## CLASS METHODS ##########
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(dog)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog_row = DB[:conn].execute(sql, dog[:name], dog[:breed])

    if !dog_row.empty?
      row = dog_row[0]
      new_dog = Dog.new_from_db(row)
    else
      new_dog = self.create(dog)
    end
    new_dog
  end

  def self.new_from_db(row)
    hash = {}
    hash[:name] = row[1]
    hash[:breed] = row[2]

    new_dog = Dog.new(hash, row[0])
  end

  ########## INSTANCE METHODS ##########
  def initialize(attributes, id=nil)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = id
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      value = DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      # binding.pry
    end
    # binding.pry
    self 
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end #end of Dog class

class Dog

  attr_accessor :id, :name, :breed

  @@all = []

  def self.all
    @@all
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed

    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(name: name, breed: breed)
    Dog.new(name: name, breed: breed).save
  end

  def self.exist_check(name: name, breed: breed)
    Dog.all.select do |dog|
      name == dog.name && breed == dog.breed
    end
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    if Dog.exist_check(name: name, breed: breed).empty?
      new_dog = Dog.create(name: name, breed: breed)
      new_dog.id = id
      new_dog
    end
  end

  def self.find_or_create_by(name: name, breed: breed)
    # check = Dog.exist_check(name: name, breed: breed)
    # if !check.empty?
    #   check[0]
    # else
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
      SQL

      db_check = DB[:conn].execute(sql, name, breed)

      if !db_check.empty?
        self.find_by_id(db_check[0][0])
      else
        Dog.create(name: name, breed: breed)
      end
    # end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
end

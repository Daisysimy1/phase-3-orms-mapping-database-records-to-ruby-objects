
class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  # drop table
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  # create the songs table
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  # insert the records into the table
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.album)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    end
  end
  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL
   
    DB[:conn].execute(sql, self.name, self.album)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    self
  end
  
  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    self.new(id:row[0],name:row[1],album:row[2])
  end

  def self.all
    DB[:conn].execute("SELECT * FROM songs").map do |row|
       self.new_from_db(row)
    end
  end
  

  # retrieve a song by name
  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
    # binding.pry
    result = DB[:conn].execute(sql, name)[0]
    Song.new(result[0], result[1], result[2])
  end

  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end

  # prevent creation of duplicate records
  # create a find_or_create_by method

  def self.find_by_name(name)
    query=<<-SQL
    SELECT * FROM songs
    WHERE name=?
    LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(query,name).first)
  end
end
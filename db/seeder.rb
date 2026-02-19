require 'sqlite3'

class Seeder

  DB_PATH = 'db/strong_bakes.db'

  def self.seed!
    puts "Klart! Strong Bakes databas är redo."
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS products')
  end

  def self.create_tables
    db.execute('CREATE TABLE products (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  smak TEXT NOT NULL,
                  topping TEXT NOT NULL,
                  pris TEXT,
                  category_id INTEGER)')
  end

  def self.populate_tables
    db.execute('INSERT INTO products (smak,  pris) VALUES ("Choco-Muscle Crunch", "25kr")')
    db.execute('INSERT INTO products (smak,  pris) VALUES ("Salted Caramel Pump", "25kr")')
    db.execute('INSERT INTO products (smak,  pris) VALUES ("Vanilla Power Swirl", "25kr")')
    db.execute('INSERT INTO products (smak,  pris) VALUES ("Apple Beast", "25kr")')
  end

  private

  def self.db
    @db ||= begin
      Dir.mkdir('db') unless Dir.exist?('db')
      
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end
end
Seeder.seed!
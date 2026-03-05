require 'sqlite3'

class Seeder
  DB_PATH = 'db/strong_bakes.db'

  def self.seed!
    drop_tables
    create_tables
    populate_tables
    puts "Klart! Strong Bakes databas är redo med varukorg."
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS cart')
    db.execute('DROP TABLE IF EXISTS products')
  end

  def self.create_tables
    db.execute('CREATE TABLE products (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  smak TEXT NOT NULL,
                  pris INTEGER NOT NULL,
                  category_id INTEGER)')

    db.execute('CREATE TABLE cart (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  product_id INTEGER NOT NULL,
                  quantity INTEGER)')
  end

  def self.populate_tables
    db.execute('INSERT INTO products (smak, pris) VALUES ("Choco-Muscle Crunch", 25)')
    db.execute('INSERT INTO products (smak, pris) VALUES ("Salted Caramel Pump", 25)')
    db.execute('INSERT INTO products (smak, pris) VALUES ("Vanilla Power Swirl", 30)')
    db.execute('INSERT INTO products (smak, pris) VALUES ("Apple Beast", 20)')
    

    db.execute('INSERT INTO cart (product_id, quantity) VALUES (1, 2)')
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

Seeder.drop_tables
Seeder.create_tables
Seeder.populate_tables
Seeder.seed!
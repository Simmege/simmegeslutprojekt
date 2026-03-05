require 'sinatra/base'
require 'sqlite3'
require 'debug'
require 'awesome_print'

DB_PATH = 'db/strong_bakes.db'
class App < Sinatra::Base

    setup_development_features(self)


    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end




  get '/products' do
    @products = db.execute('SELECT * FROM products')
   erb :index
  end
    

    get '/add/:id' do
      db = SQLite3::Database.new('db/strong_bakes.db')
      db.execute("INSERT INTO cart (product_id, quantity) VALUES (?, 1)", params[:id])
      redirect '/products'
    end

    get '/cart' do
      db = SQLite3::Database.new('db/strong_bakes.db')
      db.results_as_hash = true
      
      @items = db.execute("
        SELECT cart.id AS cart_id, products.smak, products.pris, cart.quantity 
        FROM cart 
        JOIN products ON cart.product_id = products.id")
      
      @total = 0
      @items.each do |item|
      @total += item['pris'] * item['quantity']
      end
      erb :cart
    end

    post '/cart/:id/delete' do |id|
      db.execute("DELETE FROM cart WHERE id =?",[id]).first
  
      redirect ("/cart")
    end

    

end

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
    


    get '/cart' do
      
      @items = db.execute("
      SELECT cart.*, products.smak 
      FROM cart
      JOIN products ON cart.product_id = products.id
     ")

      erb :cart
    end


    post '/cart/:id/delete' do |id|
      
      db.execute("UPDATE cart SET quantity = quantity - 1 WHERE id = ?", [id])

      db.execute("DELETE FROM cart WHERE quantity <= 0")
      
      redirect "/cart"
    end

    get '/add/:id' do
      c_id = params[:id]
      item = db.execute("SELECT * FROM cart WHERE product_id = ?", [c_id]).first

      if item
        db.execute("UPDATE cart SET quantity = quantity + 1 WHERE product_id = ?", [c_id])
      else
        db.execute("INSERT INTO cart (product_id, quantity) VALUES (?, 1)", [c_id])
      end
      redirect "/products"
    end



    

end

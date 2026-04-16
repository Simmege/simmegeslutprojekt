require 'sinatra/base'
require 'sqlite3'
require 'debug'
require 'awesome_print'
require 'securerandom'
require 'bcrypt'

DB_PATH = 'db/strong_bakes.db'
class App < Sinatra::Base

    setup_development_features(self)


    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end
  
    before do
      if session[:user_id]
        @current_user = db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
        ap @current_user
      end
    end




  get '/products' do
    @products = db.execute('SELECT * FROM products')
   erb :index
  end
    
  get '/admin' do
    if session[:user_id]
      erb(:"admin_index")
    else
      ap "/admin : Access denied."
      status 401
      redirect '/acces_denied'
    end
  end

  get '/acces_denied' do
    erb(:acces_denied)
  end
  post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]
    user = db.execute("SELECT *
    FROM users
    WHERE username = ?",
    [request_username]).first
  

    unless user
      ap "/login : Invalid username."
      status 401
      redirect '/acces_denied'
    end
    db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s

    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    if bcrypt_db_password == request_plain_password
      ap "/login : Logged in -> redirecting to admin"
      session[:user_id] = db_id
      redirect '/admin'
    else
      ap "/login : Invalid password."
      status 401
      redirect '/acces_denied'
    end
  end

  get '/cart' do
      
      @items = db.execute("
      SELECT cart.*, products.smak, products.pris 
      FROM cart
      JOIN products ON cart.product_id = products.id
     ")

     @total_price = 0
     @items.each do |item|
      @total_price += item["quantity"] * item["pris"]
     end
      erb :cart
    end

    get '/products/create' do
      erb(:create_product)

    end

    post '/products/create' do
      p_smak = params["smak"]
      p_desc = params["beskrivning"]
      p_pris = params["pris"]
      db.execute("INSERT INTO products (smak, beskrivning, pris) VALUES (?,?,?)", [p_smak, p_desc, p_pris])
      redirect("/products")
    end
    get '/products/:id' do |id|
      @products = db.execute("SELECT * FROM products WHERE id =?", [id]).first
      erb(:show)
    end


    post '/cart/:id/delete' do |id|
      
      db.execute("UPDATE cart SET quantity = quantity - 1 WHERE id = ?", [id])

      db.execute("DELETE FROM cart WHERE quantity <= 0")
      
      redirect "/cart"
    end

    post '/add/:id' do
      c_id = params[:id]
      item = db.execute("SELECT * FROM cart WHERE product_id = ?", [c_id]).first

      if item
        db.execute("UPDATE cart SET quantity = quantity + 1 WHERE product_id = ?", [c_id])
      else
        db.execute("INSERT INTO cart (product_id, quantity) VALUES (?, 1)", [c_id])
      end
      redirect "/products"
    end

    post "/products/:id/delete" do |id|
      db.execute("DELETE FROM products WHERE id =?",[id])

      redirect ("/products")
    end

    get '/todos/:id/update' do |id|
      @product_info = db.execute("SELECT * FROM products WHERE id =?",[id]).first
      p @product_info
      erb(:edit)
    end

    post '/todos/:id/update' do |id|
      p_desc = params["beskrivning"]
  
      db.execute("UPDATE products SET description=? WHERE id =?", [p_desc, id])
  
      redirect ("/todos")
    end

    get '/login' do
     erb :login
    end



    

end

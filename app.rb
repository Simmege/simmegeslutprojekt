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

    helpers do
      def is_admin?

        !!session[:user_id]
      end

      def require_admin
        unless is admin?
          ap "Åtkomst nekad, du är inte inloggad"
          halt 401, redirect('/access_denied')
        end
      end
    end

    post '/logout' do
      session.clear
      redirect '/products'
    end



  get '/products' do
    @products = db.execute('SELECT * FROM products')
   erb :index
  end
    
  get '/admin' do
    if session[:user_id] == 1
      erb :"admin_index"
    else
      ap "/admin : Access denied."
      redirect '/products'
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
  
    p user 

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

    get '/products/new' do
      erb(:new)

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

    get '/products/:id/edit' do |id|
      @product_info = db.execute("SELECT * FROM products WHERE id =?",[id]).first
      p @product_info
      if is_admin?
        erb(:edit)
      else
        erb(:acces_denied)
      end
    end

    post '/products/:id/update' do |id|
      p_desc = params["beskrivning"]
  
      db.execute("UPDATE products SET beskrivning=? WHERE id =?", [p_desc, id])
  
      redirect ("/products")
    end

    get '/login' do
     erb :login
    end

    get "/new_user" do
      erb :new_user
    end

    post "/new_user" do
      u_user = params["username"]
      u_password = params["password"]

      password_hashed = BCrypt::Password.create(u_password)

      db.execute("INSERT INTO users (username, password) VALUES (?,?)", [u_user, password_hashed])
      redirect("/products")
    end



    

end

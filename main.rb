require 'date'
require 'pry'
require 'json'

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

require "./db_config"
require './models/user'
require './models/food_item'

require 'fatsecret'
FatSecret.init('12c2ef215e604e3f8ed6853dfe478390','7cb2062d9146486eb1a137ace3819a2a')

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def bmr
    if current_user.gender == 'Male'
      rate = 10 * current_user.weight + 6.25 * current_user.height - 5 * current_user.age + 5
    else
      rate = 10 * current_user.weight + 6.25 * current_user.height - 5 * current_user.age - 161
    end
    rate
  end

end

after do
  ActiveRecord::Base.connection.close
end

# The main page, shows a login form
get '/' do
  redirect to '/dashboard' unless !logged_in?   # if logged in, show the user dashboard
  erb :login
end

# Actually logging in
post '/' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    # logged in, create a new session
    session[:user_id] = user.id
    # redirect
    redirect to '/'
  else
    # stay  at the login form
    erb :login
  end
end

# shows a signup form
get '/signup' do
  erb :signup
end

# creating a new user
post '/signup' do
  user = User.new
  user.email = params[:email]
  user.password = params[:password]
  user.name = params[:name]
  user.age = params[:age]
  user.weight = params[:weight]
  user.height = params[:height]
  user.gender = params[:gender]
  user.save
  redirect to '/'
end

# displays user data
get '/dashboard' do
  erb :index
end

# log out
delete '/' do
  session[:user_id] = nil
  redirect to '/'
end

get '/food_items' do
  @food_items = Food_Item.where(user_id: current_user.id)
  erb :food_items
end

post '/food_items' do
  food_item = Food_Item.new
  food_item.name = params[:name]
  food_item.calories = params[:calories].to_i
  food_item.day = params[:date]
  #food_item.day = Date.today
  food_item.user_id = current_user.id
  food_item.save
  redirect to '/food_items'
end

get '/edit' do
  erb :edit
end

put '/edit' do
  user = current_user
  user.name = params[:name]
  user.age = params[:age]
  user.weight = params[:weight]
  user.height = params[:height]
  user.gender = params[:gender]
  user.save
  redirect to '/dashboard'
end

delete '/food_items' do
  params[:ids].each do |id|
    Food_Item.destroy id
  end
  {success: true}.to_json
end

delete '/dashboard' do
  user = current_user
  user.delete
  redirect to '/'
end

post '/food' do
  results = FatSecret.search_food(params[:food_name])
  @result = results["foods"]["food"]
  erb :food
end

get '/food' do
  erb :food
end

get '/food_details' do
  @single_result = FatSecret.food(params[:food_id])["food"]
  erb :food_details
end

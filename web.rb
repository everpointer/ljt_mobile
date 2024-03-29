# encoding: utf-8
require 'rubygems'
require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?
require 'data_mapper'
require 'haml'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

helpers do
  def order_status(status)
    case status
    when "created"
      "未处理"
    when "cancel"
      "用户取消"
    when "removed"
      "管理员作废"
    when "confirmed"
      "已确认"
    else
      "异常状态"
    end
  end
end

configure do
  enable :sessions
  # load models
  Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require model }
  # without this, model operation may fail (console)
  DataMapper.finalize
end

before '/products' do
  platform = params[:from]
  username = params[:username]
  if settings.development?
    platform ||= 'wx'  
    username ||= 'laoyufu'
  end
  if platform && username
    session[:username] = username
    unless User.first(:name => username)
      User.create(:name => username, :platform => platform)
    end
  end
end

before do
  pass if request.path_info.include? "/orders/history/"
  halt "User session not exist!" unless session[:username]
  @current_user = User.first(:name => session[:username])
end

get '/products' do
  @products = Product.all
  haml :products 
end

post '/order' do
  order = Order.create(params[:order])
  order.user = @current_user
  if order.save
    order_details = params[:order_details] && params[:order_details].length >=2 ? JSON.parse(params[:order_details]): []
    order_details.each do |order_detail|
      order_detail[:unit_price] = order_detail['unit_price'].to_d
      order.order_details << OrderDetail.new(order_detail)
    end
    order.order_details.save
    redirect "/orders/#{order.id}/edit"
  else
    "Error: #{order.errors.inspect}"
  end
end

get '/orders/:id/edit' do
  @order = Order.get(params[:id])
  @order_details = @order.order_details
  @total_price = @order_details.inject(0) do |sum, order_detail|
    sum + order_detail[:unit_price]*order_detail[:quantity]
  end
  haml :edit_order
end

put '/orders/:id' do
  @order = Order.get(params[:id])
  if @order.update(params[:order])
    haml :order_finish  
  else
    "shit!"
  end
end

get '/orders/history/:username' do
  user = User.first(:name => params[:username])  
  
  history_orders = []
  if user 
    user.orders.each do |order|
      total_price = order.order_details.inject(0) do |sum, order_detail|
        sum + order_detail[:unit_price]*order_detail[:quantity]
      end
      history_orders << {:order_number => order.order_number, :total_price => total_price, :created_at => order.created_at}
    end
  end

  json :orders => history_orders
end

# order ajax api route

put '/api/orders/confirm' do
  order_id_list = JSON.parse(params[:order_id_list]) || []

  if params[:operation] == "confirm"
    status = "confirmed"
  elsif params[:operation] == "unconfirm"
    status = "created"
  else
    halt 400, "Wrong request parameters!"
  end
  
  unless Order.all(:id => order_id_list).update(:status => status)
    halt 500, "Order update operation failed!"
  end
  
  "Update successfully!"
end

# admin routes

get '/admin' do
  status_filter = params[:status_filter]
  query = params[:query]

  @orders = Order.all()
  if (status_filter)
    @orders &= Order.status(status_filter)
  end
  if (query)
    @orders &= Order.query(query)
  end
  @order_details = []

  haml :admin_orders, :layout => :admin_layout
end


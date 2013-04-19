# encoding: utf-8
require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'data_mapper'
require 'haml'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

helpers do
end

configure do
  # load models
  Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require model }
  # without this, model operation may fail (console)
  DataMapper.finalize
end

before do
  @current_user = User.first(:name => 'laoyufu')
end

get '/products' do
  @products = Product.all  
  haml :products 
end

post '/order' do
  order = Order.create(params[:order])
  order.user = @current_user
  if order.save
    order_details = JSON.parse(params[:order_details])
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


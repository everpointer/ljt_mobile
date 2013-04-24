require 'data_mapper'

class User
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String
  property :created_at,   DateTime
  property :platform,     String

  has n, :orders
end

class Product
  include DataMapper::Resource

  property :id,               Serial
  property :name,             String
  property :unit_price,       Decimal
  property :created_at,       DateTime
  property :category,         String

  has n, :order_details
end

class Order
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :receiver_name, String
  property :mobile,     String
  property :address,    String
  property :order_number, String
  property :status, String, :default => "created" # statuses: created, cancel, removed, confirmed

  belongs_to :user
  
  has n, :order_details
  has n, :products, :through => :order_details

  before :create, :generate_order_number

  def total_price
    self.order_details.inject(0) do |sum, order_detail|
      sum + order_detail[:unit_price]*order_detail[:quantity]
    end
  end

  # scopes
  def self.status(status_filter)
    all(:status => status_filter)
  end

  def self.query(query_str)
    query_str.strip!

    if query_str == ""
      all()
    elsif query_str =~ %r{\d{16}}  # order number
      all(:order_number => query_str)
    elsif query_str =~ %r{\d{8}|\d{11}}
      all(:mobile.like => "%#{query_str}%")
    else
      all(:receiver_name.like => "%#{query_str}%") | all(:address.like => "%#{query_str}%")
    end
  end

  private

  def generate_order_number
    # generate 16 bit order number
    self.order_number = self.created_at.to_time.to_i.to_s + "%06d" % SecureRandom.random_number(999999)
    self.save!
  end
end

class OrderDetail
  include DataMapper::Resource

  property :id,             Serial
  property :quantity,       Integer
  property :unit_price,     Decimal
  property :created_at,     DateTime

  belongs_to :order
  belongs_to :product
end

DataMapper.auto_upgrade!

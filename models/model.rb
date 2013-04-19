require 'data_mapper'

class User
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String
  property :created_at,   DateTime
  property :platform,     String
end

class Product
  include DataMapper::Resource

  property :id,               Serial
  property :name,             String
  property :unit_price,       Decimal
  property :created_at,       DateTime

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

  belongs_to :user
  
  has n, :order_details
  has n, :products, :through => :order_details

  before :create, :generate_order_number

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

# == Schema Information
#
# Table name: customers
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Customer < ActiveRecord::Base
  belongs_to :user
  has_many :accounts
  has_many :customer_institutions

  MIN_CUSTOMER_ID = 2
  MAX_CUSTOMERS = 4

  def Customer.try_create user
    if Customer.count < MAX_CUSTOMERS
      Customer.create id: Customer.maximum('id') || MIN_CUSTOMER_ID,
                      user: user
    end
  end
end

class Account < ActiveRecord::Base
  belongs_to :customer
  belongs_to :institution
end

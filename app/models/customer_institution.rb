class CustomerInstitution < ActiveRecord::Base
  belongs_to :customer
  belongs_to :institution
  validates :customer_id, presence: true
  validates :institution_id, presence: true
  validates :name, presence: true
end

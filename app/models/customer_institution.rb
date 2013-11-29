class CustomerInstitution < ActiveRecord::Base
  belongs_to :customer
  belongs_to :institution
  validates :customer_id, presence: true
  validates :institution_id, presence: true
  validates :name, presence: true
end

# == Schema Information
#
# Table name: customer_institutions
#
#  id             :integer         not null, primary key
#  customer_id    :integer
#  institution_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#

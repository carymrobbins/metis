# == Schema Information
#
# Table name: transactions
#
#  id                         :integer         not null, primary key
#  account_id                 :integer
#  currency_type              :string(255)
#  institution_transaction_id :string(255)
#  payee_name                 :string(255)
#  posted_date                :datetime
#  user_date                  :datetime
#  amount                     :decimal(, )
#  pending                    :boolean
#  created_at                 :datetime
#  updated_at                 :datetime
#

class Transaction < ActiveRecord::Base
  belongs_to :account
end

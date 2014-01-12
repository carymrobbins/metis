class Account < ActiveRecord::Base
  belongs_to :customer
  belongs_to :institution
  alias_attribute :account_id, :id

  def latest_transactions
    @latest_transactions ||= Transaction.where(
        account_id: id
    ).order('user_date desc').take(10)
  end

  def customer_institution
    @customer_institution ||= CustomerInstitution.find_by_institution_id(
        institution_id)
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id                       :integer(8)      not null, primary key
#  customer_id              :integer
#  status                   :string(255)
#  account_number           :string(255)
#  account_nickname         :string(255)
#  display_position         :integer
#  institution_id           :integer(8)
#  description              :string(255)
#  balance_amount           :decimal(, )
#  balance_date             :datetime
#  last_txn_date            :datetime
#  aggr_success_date        :datetime
#  aggr_attempt_date        :datetime
#  aggr_status_code         :string(255)
#  currency_code            :string(255)
#  institution_login_id     :integer(8)
#  banking_account_type     :string(255)
#  available_balance_amount :decimal(, )
#  created_at               :datetime
#  updated_at               :datetime
#


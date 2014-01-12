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

  def Customer.try_create(user)
    if Customer.count < MAX_CUSTOMERS
      Customer.create id: (Customer.maximum('id') || MIN_CUSTOMER_ID) + 1,
                      user: user
    end
  end

  def sync_accounts
    client = Aggcat.scope id
    response = client.accounts
    # TODO: Just supporting banking accounts right now.  Need to update the
    # TODO: schema for credit, loan, etc. fields.
    # Data may be an Array of Hash or a single Hash.  Normalize to an Array.
    account_data = Array(response[:result][:account_list][:banking_account])

    # Clean out pending transactions since they are unreliable.
    Transaction.where(
        'account_id in (:ids) and pending',
        ids: account_data.map{|a| a[:account_id]}
    ).destroy_all

    Account.upsert account_data, translation: {:account_id => :id},
                   constants: {customer_id: id}
    transaction_data = []
    # Hash of account_id, error_message
    transaction_errors = {}
    account_data.each do |row|
      account_id = row[:account_id]
      response = client.account_transactions row[:account_id],
                                             Transaction::SYNC_TIME_RANGE.ago
      if /20\d/.match response[:status_code]
        # Data may be an Array of Hash or a single Hash.  Normalize to an Array.
        transaction_data += Array(
            response.fetch_nested(:result, :transaction_list,
                                  :banking_transaction)
        # Ignore categorization for now, this doesn't work well.
        # Merge in account_id into the data.
        ).map{|t| t.except(:categorization).merge(account_id: account_id)}
      else
        transaction_errors[account_id] =
            response.fetch_nested :result, :status, :error_info, :error_message
      end
    end
    Transaction.upsert transaction_data, constants: {customer_id: id}
  end
end

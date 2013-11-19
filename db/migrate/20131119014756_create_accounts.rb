class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :customer, index: true
      t.string :status
      t.string :account_number
      t.string :account_nickname
      t.integer :display_position
      t.references :institution, index: true
      t.string :description
      t.decimal :balance_amount
      t.datetime :balance_date
      t.datetime :last_txn_date
      t.datetime :aggr_success_date
      t.datetime :aggr_attempt_date
      t.string :aggr_status_code
      t.string :currency_code
      t.integer :institution_login_id
      t.string :banking_account_type
      t.decimal :available_balance_amount

      t.timestamps
    end
  end
end

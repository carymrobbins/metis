class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :account, index: true
      t.string :currency_type
      t.string :institution_transaction_id
      t.string :payee_name
      t.datetime :posted_date
      t.datetime :user_date
      t.decimal :amount
      t.bool :pending

      t.timestamps
    end
  end
end

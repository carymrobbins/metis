class ChangePksToBigint < ActiveRecord::Migration
  def change
    { :institutions => [:id],
      :accounts => [:id, :institution_id, :institution_login_id],
      :transactions => [:id, :account_id]
    }.each do |table, fields|
      fields.each do |field|
        change_column table, field, :integer, limit: 8
      end
    end
  end
end

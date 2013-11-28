# == Schema Information
#
# Table name: accounts
#
#  id                       :integer         not null, primary key
#  customer_id              :integer
#  status                   :string(255)
#  account_number           :string(255)
#  account_nickname         :string(255)
#  display_position         :integer
#  institution_id           :integer
#  description              :string(255)
#  balance_amount           :decimal(, )
#  balance_date             :datetime
#  last_txn_date            :datetime
#  aggr_success_date        :datetime
#  aggr_attempt_date        :datetime
#  aggr_status_code         :string(255)
#  currency_code            :string(255)
#  institution_login_id     :integer
#  banking_account_type     :string(255)
#  available_balance_amount :decimal(, )
#  created_at               :datetime
#  updated_at               :datetime
#

class Account < ActiveRecord::Base
  belongs_to :customer
  belongs_to :institution
  alias_attribute :account_id, :id

  # This upsert method should really be available to all ActiveRecord::Base.
  # Performs an insert, update, and/or delete in a single SQL query.  Note that
  # this will only work with PostgreSQL.
  # Params:
  # - data: Array of Hash to be upserted.
  # - translation: Hash to map keys in data elements to fields in the database.
  # - constants: Hash of constants to merge into every data row.
  # - field_names: Array of field names to use from data for the upsert.  These
  #                should match your database, not your upsert data. By default
  #                this will be determined by the translated keys of your first
  #                data row.
  # - pk: Name of primary key field.  Defaults to 'id'.
  # - delete: If true, perform deletes for primary keys not in data.
  #           Default false.
  def self.upsert(data, translation: {}, constants: {}, field_names: nil,
                  pk: 'id', delete: false)
    # Generate field_names from user argument or first row of data.
    field_names = (field_names || data[0].keys + constants.keys).map do |f|
      # Translate the field_names
      (translation[f] || f).to_s
      # Sort them to ensure the are inserted into SQL in the right order.
    end.sort
    field_names_joined = field_names.join(',')
    # Create '(?, ?, ...), (?, ?, ...)' token list to interpolate into SQL.
    # Only the first row needs type annotations.
    head_tokens = field_names.map do |f|
      col = self.column_types[f]
      t = col.try(:sql_type)
      # HACK: Can't get the sql_type for :datetime for some reason, so let's
      # HACK: fudge it.
      t = 'timestamp without time zone' if t.nil? && col.type == :datetime
      '?' + (t ? "::#{t}" : '')
    end
    head_tokens = "(#{head_tokens.join(',')})"
    row_tokens = (%w(?) * field_names.length).join(',')
    row_tokens = "(#{row_tokens})"
    tail_tokens_joined = ([row_tokens] * (data.length - 1)).join(',')
    tokens_joined = [head_tokens, tail_tokens_joined].join(',')
    translated_data = data.map do |row|
      # Translate the keys of each row to field_names.
      row.merge(constants).map do |k, v|
        [(translation[k] || k).to_s, v]
      # Only use field_names
      end.select do |k, _|
        field_names.include? k
      # Sort to ensure values are passed into SQL correctly.
      end.sort_by do |k, _|
        k
      # Extract the value for each row to pass it into SQL.
      end.map do |_, v|
        v
      end
      # Flatten the rows to pass to the SQL sanitizer.
    end.flatten
    # Generate writable CTEs to perform upsert.
    values_sql = "cte_values(#{field_names_joined}) as (
      values #{tokens_joined}
    )"
    set_clause = field_names.map{|f| "#{f} = cte_values.#{f}"}.join(',')
    update_sql = "cte_update as (
      update #{self.table_name}
      set #{set_clause}
      from cte_values
      where #{self.table_name}.#{pk} = cte_values.#{pk}
      returning #{self.table_name}.#{pk}
    )"
    insert_sql = "cte_insert as (
      insert into #{self.table_name}(#{field_names_joined})
      select #{field_names_joined}
      from cte_values
      where #{pk} not in (select #{pk} from cte_update)
      returning #{self.table_name}.#{pk}
    )"
    delete_sql = "cte_delete as (
      delete from #{self.table_name}
      where #{pk} not in (select #{pk} from cte_values)
      returning #{pk}
    )"
    delete_count_sql = 'select count(*) from cte_delete'
    cte = [values_sql, update_sql, insert_sql]
    # Include the delete CTE if the user passed `delete: true`.
    cte << delete_sql if delete
    final_sql_template = "with #{cte.join(',')}
      select (select count(*) from cte_update) as updated,
             (select count(*) from cte_insert) as inserted,
             (#{delete ? delete_count_sql : 0}) as deleted"
    sanitized_sql =
        ActiveRecord::Base.send :sanitize_sql_array,
                                [final_sql_template, *translated_data]
    ActiveRecord::Base.connection.execute sanitized_sql
  end
end

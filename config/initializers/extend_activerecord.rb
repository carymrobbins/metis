class ActiveRecord::Base
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
  # - delete: If true, perform deletes for primary keys not in data.
  #           Default false.
  # - auto_timestamp: If fields created_at and updated_at exist on the model,
  #                   automatically update them accordingly.
  def self.upsert(data, translation: {}, constants: {}, field_names: nil,
                  delete: false, auto_timestamp: true)
    pk = self.primary_key
    # Generate field_names from user argument or first row of data.
    field_names = (field_names || data[0].keys + constants.keys).map do |f|
      # Translate the field_names
      (translation[f] || f).to_s
      # Sort them to ensure they are inserted into SQL in the right order.
    end.sort
    field_types = Hash[self.columns.map{|c| [c.name, c.sql_type]}]
    field_names_joined = field_names.join(',')
    # Create '(?, ?, ...), (?, ?, ...)' token list to interpolate into SQL.
    # Only the first row needs type annotations.
    head_tokens =
        '(' + field_names.map{|f| "?::#{field_types[f]}"}.join(',') + ')'
    row_tokens =
        '(' + (%w(?) * field_names.length).join(',') + ')'
    tail_tokens_joined = ([row_tokens] * (data.length - 1)).join(',')
    tokens_joined = [head_tokens, tail_tokens_joined].join(',')
    translated_data = data.map do |row|
      # Translate the keys of each row to field_names.
      translated_row = Hash[row.merge(constants).map do |k, v|
        [(translation[k] || k).to_s, v]
      end]
      # Ensure all field names are present by injecting null if missing.
      field_names.each do |f|
        translated_row[f] = nil unless translated_row.include? f
      end
      # Remove data when field is not in field_names.
      translated_row.select do |k, _|
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
          #{auto_timestamp ? ', updated_at = current_timestamp' : ''}
      from cte_values
      where #{self.table_name}.#{pk} = cte_values.#{pk}
      returning #{self.table_name}.#{pk}
    )"

    insert_sql = "cte_insert as (
      insert into #{self.table_name}(
        #{field_names_joined}
        #{auto_timestamp ? ', created_at, updated_at' : ''}
      )
      select #{field_names_joined}
             #{auto_timestamp ? ', current_timestamp, current_timestamp' : ''}
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

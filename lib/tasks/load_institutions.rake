desc 'Load institutions from a YAML file.'
task :load_institutions, [:file] => :environment do |t, args|
  field_map = [
      [:id, :institution_id],
      [:name, :institution_name],
      [:home_url, :home_url],
      [:phone_number, :phone_number],
  ]
  unless args.file
    puts 'Usage: rake load_institutions[FILE.yml]'
    return
  end
  data = YAML.load(File.read(args.file))
  results = data[:result][:institutions][:institution]
  institutions = results.map{|x| field_map.map{|_, v| x[v] }}
  sql = ActiveRecord::Base.send :sanitize_sql_array, ["
    with base(id, name, home_url, phone_number) as (
      values #{(%w((?::int,?,?,?))*institutions.length).join ','}
    ), deleting as (
      delete from institutions
      where id not in (select id from base)
      returning id
    ), updating as (
      update institutions
      set name = base.name,
          home_url = base.home_url,
          phone_number = base.phone_number,
          updated_at = current_timestamp
      from base
      where institutions.id = base.id
      returning institutions.id
    )
    insert into institutions(
                id, name, home_url, phone_number, created_at, updated_at)
    select id, name, home_url, phone_number, current_timestamp, current_timestamp
    from base
    where id not in (select id from updating)
  ", *institutions.flatten]
  ActiveRecord::Base.connection.execute sql
end

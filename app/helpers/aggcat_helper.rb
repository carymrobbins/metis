module AggcatHelper
  def key_file(name)
    Rails.root.join('config', "#{name}.intuit.key")
  end
  
  Aggcat.configure do |config|
    config.issuer_id = File.read(key_file('issuer'))
    config.consumer_key = File.read(key_file('consumer'))
    config.consumer_secret = File.read(key_file('secret'))
    config.certificate_path = key_file('certificate')
  end
end

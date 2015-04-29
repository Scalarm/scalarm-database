Dir[File.join(File.dirname(__FILE__), 'model' ,'*.rb')].each do |f|
  require f
end
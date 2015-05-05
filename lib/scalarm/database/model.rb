this_dir = File.dirname(__FILE__)
Dir[File.join(this_dir, 'model', '*.rb')].each do |f|
  require_relative f
end
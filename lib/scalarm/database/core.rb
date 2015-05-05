this_dir = File.dirname(__FILE__)
Dir[File.join(this_dir, 'core', '*.rb')].each do |f|
  require_relative f
end
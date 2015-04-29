Dir['core/*.rb'].each do |f|
  require_relative f
end
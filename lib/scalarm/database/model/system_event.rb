require 'scalarm/database/core/mongo_active_record'

module Scalarm::Database::Model
  class SystemEvent < Scalarm::Database::MongoActiveRecord
    use_collection 'system_events'
  end
end
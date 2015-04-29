require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class MongoLockRecord < Scalarm::Database::MongoActiveRecord
    def self.collection_name
      'mongo_locks'
    end
  end
end

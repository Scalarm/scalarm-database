module Scalarm
  module DbModel
    class MongoLockRecord < MongoActiveRecord
      def self.collection_name
        'mongo_locks'
      end
    end
  end
end

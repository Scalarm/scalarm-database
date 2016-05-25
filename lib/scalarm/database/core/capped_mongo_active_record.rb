require_relative 'mongo_active_record'

module Scalarm::Database
  class CappedMongoActiveRecord < MongoActiveRecord

    # returns a reference to mongo collection based on collection_name abstract method
    def self.collection
      class_collection = @@db.collection_names.include?(self.collection_name) ?
          @@db[self.collection_name] : create_capped_collection

      raise "Error while connecting to #{self.collection_name}" if class_collection.nil?

      class_collection
    end

    def self.create_capped_collection
      if @@db.collection_names.include?(self.collection_name)
        @@db[self.collection_name]
      else
        cc = @@db[self.collection_name, capped: true, size: self.capped_size, max: self.capped_max]
        cc.create
        cc
      end
    end

    def self.capped_size
      1048576
    end

    def self.capped_max
      10000
    end

  end
end
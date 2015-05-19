require 'scalarm/database/core/mongo_active_record'

module DBHelper

  DATABASE_NAME = 'scalarm_db_test'

  def setup
    Scalarm::Database::MongoActiveRecord.set_encryption_key('test_key')

    unless Scalarm::Database::MongoActiveRecord.connected?
      raise StandardError.new('Connection to database failed') unless Scalarm::Database::MongoActiveRecord.connection_init('localhost', DATABASE_NAME)
      puts "Connecting to database #{DATABASE_NAME}"
    end
  end

  # Drop all collections after each test case.
  def teardown
    db = Scalarm::Database::MongoActiveRecord.get_database(DATABASE_NAME)
    db.collections.each do |collection|
      collection.remove unless collection.name.start_with? 'system.'
    end
  end
end
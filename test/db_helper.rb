require 'scalarm/database/core/mongo_active_record'

module DBHelper

  DATABASE_NAME = 'scalarm_db_test'

  def setup
    Scalarm::Database::MongoActiveRecord.set_encryption_key('test_key')

    unless Scalarm::Database::MongoActiveRecord.connected?
      unless Scalarm::Database::MongoActiveRecord.connection_init('localhost', DATABASE_NAME)
        raise StandardError.new('Connection to database failed')
      end
      puts "Connecting to database #{DATABASE_NAME}"
    end
  end

  # Drop all collections after each test case.
  def teardown
    Scalarm::Database::MongoActiveRecord.connection_init('localhost', DATABASE_NAME)
    db = Scalarm::Database::MongoActiveRecord.get_database(DATABASE_NAME)
    db.drop
  end
end
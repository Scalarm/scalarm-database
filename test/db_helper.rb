require 'scalarm/database/core/mongo_active_record'

module DBHelper

  def setup(db_config=nil)
    db_config ||= Rails.application.secrets.database
    default_mongodb_host = db_config['host'] || 'localhost'
    default_mongodb_db_name = db_config['db_name'] || 'scalarm_db_test'

    puts "MongoDB configuration: #{db_config}"
    puts "Connecting to database #{default_mongodb_host} --- #{default_mongodb_db_name}"

    Scalarm::Database::MongoActiveRecord.set_encryption_key(db_config['db_secret_key'] || 'test_key')

    unless Scalarm::Database::MongoActiveRecord.connected?
      unless Scalarm::Database::MongoActiveRecord.connection_init(default_mongodb_host, default_mongodb_db_name)
        raise StandardError.new('Connection to database failed')
      end
    end
  end

  # Drop all collections after each test case.
  def teardowndb_config=nil
    db_config ||= Rails.application.secrets.database
    default_mongodb_host = db_config['host'] || 'localhost'
    default_mongodb_db_name = db_config['db_name'] || 'scalarm_db_test'

    puts db_config

    Scalarm::Database::MongoActiveRecord.connection_init(default_mongodb_host, default_mongodb_db_name)
    db = Scalarm::Database::MongoActiveRecord.get_database(default_mongodb_db_name)
    db.drop
  end
end
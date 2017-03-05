require 'minitest/autorun'
require 'mocha/mini_test'

require 'scalarm/database/core/mongo_active_record'

class ConnectionInitTest < MiniTest::Test
  def rails_mock
    if not defined? Rails or Rails.methods.grep(/application/).empty?
      secrets = mock('object')
      secrets.stubs(:database).returns({})
      application = mock('object')
      application.stubs(:secrets).returns(secrets)

      rails_module = Class.new(Object)
      if not defined? Rails
        ConnectionInitTest.const_set("Rails", rails_module)
      end

      Rails.stubs(:application).returns(application)
    end
  end

  def test_localhost_get_collection
    rails_mock
    db_config = Rails.application.secrets.database
    puts db_config
    default_mongodb_host = db_config['host'] || 'localhost'
    default_mongodb_db_name = db_config['db_name'] || 'scalarm_db_test'

    init_result = Scalarm::Database::MongoActiveRecord.connection_init(default_mongodb_host, default_mongodb_db_name)
    assert (init_result == true), "connection: #{init_result.to_s}, is a mongodb running on #{default_mongodb_host}?"
    collection = Scalarm::Database::MongoActiveRecord.get_collection('test1')
    refute_nil collection
    collection.insert_one(hello: 'world')
    record = collection.find({hello: 'world'}, {limit: 1}).first
    assert 'world', record['hello']
  end
end
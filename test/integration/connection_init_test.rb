require 'minitest/autorun'
require 'mocha/mini_test'

require 'scalarm/database/core/mongo_active_record'

class ConnectionInitTest < MiniTest::Test
  def test_localhost_get_collection
    # TODO: drop collection first
    init_result = Scalarm::Database::MongoActiveRecord.connection_init('localhost', 'scalarm_test_database')
    assert (init_result == true), "connection: #{init_result.to_s}, is mongo running on localhost?"
    collection = Scalarm::Database::MongoActiveRecord.get_collection('test1')
    refute_nil collection
    collection.insert_one(hello: 'world')
    record = collection.find({hello: 'world'}, {limit: 1}).first
    assert 'world', record['hello']
  end
end
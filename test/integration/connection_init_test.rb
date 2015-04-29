require 'minitest/autorun'
require 'mocha/mini_test'

require 'scalarm/db_model/core/mongo_active_record'

class ConnectionInitTest < MiniTest::Test
  def setup
    # TODO do something with logger
    # TODO move up
    @logger_mock = stub_everything 'logger' do
      stubs(:debug)
      stubs(:info)
      stubs(:warn)
      stubs(:error)
    end
    Rails.stubs(:logger).returns(@logger_mock)
  end

  def test_localhost_get_collection
    # TODO: drop collection first
    init_result = Scalarm::DbModel::MongoActiveRecord.connection_init('localhost', 'scalarm_test_db')
    assert (init_result == true), "connection: #{init_result.to_s}, is mongo running on localhost?"
    collection = Scalarm::DbModel::MongoActiveRecord.get_collection('test1')
    refute_nil collection
    collection.save(hello: 'world')
    record = collection.find({hello: 'world'}, {limit: 1}).first
    assert 'world', record['hello']
  end
end
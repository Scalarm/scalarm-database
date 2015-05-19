require 'minitest/autorun'
require 'mocha/test_unit'

require 'scalarm/database/core'

class EncryptedMongoActiveRecordTest < MiniTest::Test

  def setup
    Scalarm::Database::MongoActiveRecord.set_encryption_key('test_key')
  end

  class SomeRecord < Scalarm::Database::EncryptedMongoActiveRecord
  end

  def test_exclude_secrets_to_h
    record = SomeRecord.new({})
    record.secret_password = 'password'
    record.login = 'login1'

    hashed = record.to_h

    assert_includes hashed.keys, 'login'
    assert_equal 'login1', hashed['login']
    refute_includes hashed.keys, 'secret_password'
    refute_includes hashed.keys, 'password'
  end

end
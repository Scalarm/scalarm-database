require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/model/simulation_manager_temp_password'

class ForeignKeyWriteReadTest < MiniTest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  require 'scalarm/database/core/mongo_active_record'
  class One < Scalarm::Database::MongoActiveRecord;
    use_collection 'ones'
  end
  class Two < Scalarm::Database::MongoActiveRecord;
    use_collection 'twos'
  end

  # Given:
  #   A record with foreign key (*_id field name)
  # When:
  #   Reading foreign key value
  # Then:
  #   Class of value should be a BSON::ObjectId
  def test_every_foreign_key_should_be_accessed_as_an_objectid
    one = One.new(two_id: BSON::ObjectId.new.to_s)

    assert_kind_of BSON::ObjectId, one.two_id
  end

  # Given:
  #   A record with foreign key (*_id field name) saved to database
  # When:
  #   Reading the record with foreign key (*_id field name) from database
  # Then:
  #   Class of value should be written as an BSON::ObjectId
  def test_every_foreign_key_should_be_stored_as_an_objectid
    One.new(two_id: BSON::ObjectId.new.to_s).save

    assert_kind_of BSON::ObjectId, One.first.two_id
  end

  # Given:
  #   A record with foreign key in database
  # When:
  #   Querying database with use of foreign key in string format
  # Then:
  #   Get the record with that foreign key regardless of FK format used
  def test_querying_with_foreign_key_should_autoconvert_stringified_object_id
    foreign_key = BSON::ObjectId.new

    record = One.new(two_id: foreign_key).save

    queried_record_s = One.where(two_id: foreign_key.to_s).first
    queried_record_oid = One.where(two_id: foreign_key).first

    assert_equal record.id.to_s, queried_record_s.id.to_s
    assert_equal record.id.to_s, queried_record_oid.id.to_s
  end

end
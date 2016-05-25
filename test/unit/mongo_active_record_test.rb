require 'minitest/autorun'
require 'mocha/mini_test'

require 'scalarm/database/core'

class MongoActiveRecordTest < MiniTest::Test

  class JoinedRecord < Scalarm::Database::MongoActiveRecord; end

  class SomeRecord < Scalarm::Database::MongoActiveRecord
    parse_json_if_string 'string_or_json'
    attr_join 'joined_record', JoinedRecord
    attr_join 'joined_record_not_cached', JoinedRecord, cached: false
  end

  def test_find_by_id_invalid
    assert_raises(BSON::ObjectId::Invalid) do
      Scalarm::Database::MongoActiveRecord.find_by_id(nil)
    end

    assert_raises(BSON::ObjectId::Invalid) do
      Scalarm::Database::MongoActiveRecord.find_by_id('bad_idea')
    end

    assert_raises(BSON::ObjectId::Invalid) do
      Scalarm::Database::MongoActiveRecord.find_all_by_id(nil)
    end

    assert_raises(BSON::ObjectId::Invalid) do
      Scalarm::Database::MongoActiveRecord.find_all_by_id('worse_idea')
    end

  end

  def test_mixed_attributes_new
    collection = mock do
      expects(:insert_one).with('a'=>2, 'b'=>3)
    end

    SomeRecord.expects(:collection).returns(collection)
    r = SomeRecord.new({a: 1, 'a'=> 2, b: 3})
    r.save
  end

  def test_mixed_attributes_modify
    collection = mock do
      expects(:update_one).with({'_id'=>1}, {'_id'=>1, 'a'=>2}, {:upsert => true})
    end

    SomeRecord.expects(:collection).returns(collection)
    r = SomeRecord.new({'_id'=>1, a: 1})
    r.a = 2
    r.save

    assert_equal 2, r.a
  end

  def test_save_if_exists
    id = mock 'id'
    record = SomeRecord.new({id: id})
    record.stubs(:id).returns(id)
    SomeRecord.stubs(:find_by_id).with(id).returns(record)

    record.expects(:save).once

    record.save_if_exists
  end

  def test_save_if_exists_false
    id = mock 'id'
    record = SomeRecord.new({id: id})
    record.stubs(:id).returns(id)
    SomeRecord.stubs(:find_by_id).with(id).returns(nil)

    record.expects(:save).never

    record.save_if_exists
  end

  def test_parse_json_if_string
    json_record = SomeRecord.new({})
    json_record.stubs(:get_attribute).with('string_or_json').returns({"a" => 1})

    string_record = SomeRecord.new({})
    string_record.stubs(:get_attribute).with('string_or_json').returns('{"b":2}')

    soj_json = json_record.string_or_json
    soj_string = string_record.string_or_json

    assert_equal({"a" => 1}, soj_json)
    assert_equal({"b" => 2}, soj_string)
  end

  def test_to_h_with_json_string
    string_record = SomeRecord.new({})
    string_record.stubs(:attributes).returns({'string_or_json' => '{"b":2}', 'other' => 'test'})
    string_record.stubs(:get_attribute).with('string_or_json').returns('{"b":2}')
    string_record.stubs(:get_attribute).with('other').returns('test')

    hashed = string_record.to_h

    assert_kind_of Hash, hashed
    assert_includes hashed, 'string_or_json'
    assert_equal({"b"=>2}, hashed['string_or_json'])
    assert_includes hashed, 'other'
    assert_equal('test', hashed['other'])
  end

  def test_attr_join
    joined_record_id = mock 'id'
    joined_record = mock 'record'
    JoinedRecord.stubs(:find_by_id).with(joined_record_id).returns(joined_record)

    record = SomeRecord.new({})
    record.stubs(:joined_record_id).returns(joined_record_id)

    assert_equal joined_record, record.joined_record
  end

  def test_attr_join_nil
    record = SomeRecord.new({})
    record.stubs(:joined_record_id).returns(nil)

    JoinedRecord.expects(:find_by_id).never

    assert_equal nil, record.joined_record
  end

  def test_attr_join_cached
    joined_record_id = mock 'id'
    joined_record = mock 'record'

    record = SomeRecord.new({})
    record.stubs(:joined_record_id).returns(joined_record_id)

    # try to get twice and check if find_by_id is executed (should not be)
    JoinedRecord.expects(:find_by_id).with(joined_record_id).once.returns(joined_record)
    assert_equal joined_record, record.joined_record
    assert_equal joined_record, record.joined_record
  end

  def test_attr_join_not_cached
    joined_record_id = mock 'id'
    joined_record = mock 'record'

    record = SomeRecord.new({})
    record.stubs(:joined_record_not_cached_id).returns(joined_record_id)

    # try to get twice and check if find_by_id is executed (should be)
    JoinedRecord.expects(:find_by_id).with(joined_record_id).twice.returns(joined_record)
    assert_equal joined_record, record.joined_record_not_cached
    assert_equal joined_record, record.joined_record_not_cached
  end

  class FirstRecord < Scalarm::Database::MongoActiveRecord
    def foo
      self.bar.to_i * 2
    end
  end

  class SecondRecord < Scalarm::Database::MongoActiveRecord
    def foo
      self.bar.to_i * 3
    end
  end

  def test_convert_a_to_b
    first = FirstRecord.new(bar: 10)

    assert_equal 20, first.foo

    second = first.convert_to(SecondRecord)

    assert_equal 20, first.foo
    assert_equal 10, second.bar
    assert_equal 30, second.foo
  end
end
require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/core'

class MongoActiveRecordTest < MiniTest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  class Sample < Scalarm::Database::MongoActiveRecord
    use_collection 'test'
  end

  def test_sample_record_lifecycle
    doc = Sample.new({a: 1})
    doc.save

    assert_equal 1, Sample.where({}).count

    doc.destroy
    assert_equal 0, Sample.where({}).count
  end

  def test_query_multiple_record
    Sample.new(a: 1).save
    Sample.new(a: 10).save
    Sample.new(a: 11).save

    assert_equal 3, Sample.where({}).count
    assert_equal 1, Sample.where(a: {'$gt' => 10}).count
  end

  def test_destroy_with_filter
    Sample.new(a: 1).save
    Sample.new(a: 10).save
    Sample.new(a: 11).save

    Sample.destroy(a: {'$gt' => 10})
    assert_equal 2, Sample.where({}).count
  end

  def test_records_one_by_one
    Sample.new(a: 1).save
    Sample.new(a: 10).save
    Sample.new(a: 11).save

    Sample.where(a: {'$gt' => 10}).each(&:destroy)

    assert_equal 2, Sample.where({}).count
  end

end
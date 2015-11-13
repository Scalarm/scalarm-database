require 'minitest/autorun'

require_relative '../db_helper'
require 'scalarm/database/model/experiment'

class MongoActiveRecordTest < MiniTest::Test
  include DBHelper


  def test_saving_records_with_dots_in_inner_hash_attributes
    e = Scalarm::Database::Model::Experiment.new({})
    e.test = "a"
    e.save

    e.test = { "a.field" => "a.value" }
    e.save

    assert true # we are expecting no exceptions
  end

end

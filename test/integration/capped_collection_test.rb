require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/model/experiment_progress_notification'

class CappedCollectionTest < Minitest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  def test_capped_collection_create
    Scalarm::Database::Model::ExperimentProgressNotification.create_capped_collection

    if Scalarm::Database::Model::ExperimentProgressNotification.collection.capped?
      puts "OK"
    else
      puts "NOT OK"
    end

    assert Scalarm::Database::Model::ExperimentProgressNotification.collection.capped?
    # ExperimentProgressNotification.new({one: 'two'}).save
    # elements_in_collection = ExperimentProgressNotification.where({}).count

    # assert_equal 1, elements_in_collection
  end
end
require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/model/simulation_manager_temp_password'

class LoggerTest < MiniTest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  def test_create_new_password
    exp_id = BSON::ObjectId.new
    Scalarm::Database::Model::SimulationManagerTempPassword.create_new_password_for('a', exp_id)

    q = Scalarm::Database::Model::SimulationManagerTempPassword.where(sm_uuid: 'a', experiment_id: exp_id)

    assert_equal 1, q.count
  end

end
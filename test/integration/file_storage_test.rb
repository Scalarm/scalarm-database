require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/model/simulation'

class FileStorageTest < MiniTest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  def test_simulation_binaries_are_stored_correctly
    scenario = Scalarm::Database::Model::Simulation.new({})
    file = File.open(File.join(__dir__, '..', '..', 'Gemfile'))

    scenario.set_simulation_binaries('Gemfile', file.read)

    assert_equal file.size, scenario.simulation_binaries_size
    assert_equal 'Gemfile', scenario.simulation_binaries_name

    scenario.destroy
    scenario.destroy

    file.close
  end

end
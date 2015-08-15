require 'minitest/autorun'
require 'mocha/mini_test'

require 'scalarm/database/model/simulation'

class SimulationTest < MiniTest::Test
  def setup
    @simulation = Scalarm::Database::Model::Simulation.new({})
  end

  # Tests valid input_parameters return data on example VirtRoll input specification
  def test_input_parameters_virtroll_case
    input_specification =
        [{"id"=>"",
         "label"=>"Devices setup",
         "entities"=>[{"label"=>"device1",
                       "id"=>"device1",
                       "parameters"=>
                           [{"label"=>"roller_length_right",
                             "id"=>"roller_length_right",
                             "type"=>"float", "min"=>47.5, "max"=>52.5}
                           ]
                      }
         ]
        }]

    @simulation.stubs(:input_specification).returns(input_specification)

    expected_parameters = {
        '___device1___roller_length_right' => 'Devices setup - device1 - roller_length_right'
    }
    assert_equal expected_parameters, @simulation.input_parameters
  end

end
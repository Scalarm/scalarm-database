require 'minitest/autorun'
require 'mocha'
require 'scalarm/database/model/experiment'

class SimulationRunTest < MiniTest::Test

  def test_types_in_input_parameters_should_be_remained
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({ "input_parameters" => {
        'main_category___main_group___parameter1' => 0,
        'main_category___main_group___parameter2' => -100.2,
        'main_category___main_group___parameter3' => "abcd"
    }})

    input_params = simulation_run.input_parameters

    assert_equal 3, input_params.size
    assert_equal 0, input_params['main_category___main_group___parameter1']
    assert_equal -100.2, input_params['main_category___main_group___parameter2']
    assert_equal "abcd", input_params['main_category___main_group___parameter3']
  end

  def test_arguments_method_response
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({ "input_parameters" => {
        'parameter1' => 0,
        'parameter2' => -100.2,
        'parameter3' => "abcd"
    }})

    input_parameters = simulation_run.arguments

    assert_equal 'parameter1,parameter2,parameter3', input_parameters
  end

  def test_values_method_response
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({ "input_parameters" => {
        'main_category___main_group___parameter1' => 0,
        'main_category___main_group___parameter2' => -100.2,
        'main_category___main_group___parameter3' => "abcd"
    }})

    input_values = simulation_run.values

    assert_equal '0,-100.2,abcd', input_values
  end

  def test_input_parameters_should_return_strings_when_based_on_arguments_and_values
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({
        "arguments" => "parameter1,parameter2,parameter3",
        "values" => "0,-100.2,abcd"
                                                                                      })

    input_params = simulation_run.input_parameters

    assert_equal 3, input_params.size
    assert_equal "0", input_params['parameter1']
    assert_equal "-100.2", input_params['parameter2']
    assert_equal "abcd", input_params['parameter3']
  end

end
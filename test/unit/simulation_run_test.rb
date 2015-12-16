require 'minitest/autorun'
require 'mocha'

class SimulationRunTest < MiniTest::Test

  def test_proper_types_in_input_parameters
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

  def test_arguments_return
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({ "input_parameters" => {
        'parameter1' => 0,
        'parameter2' => -100.2,
        'parameter3' => "abcd"
    }})

    assert_equal simulation_run.arguments, 'parameter1,parameter2,parameter3'
  end

  def test_values_return
    simulation_run = Scalarm::Database::Model::Experiment.new({}).simulation_runs.new({ "input_parameters" => {
        'main_category___main_group___parameter1' => 0,
        'main_category___main_group___parameter2' => -100.2,
        'main_category___main_group___parameter3' => "abcd"
    }})

    assert_equal simulation_run.values, '0,-100.2,abcd'
  end

  def test_input_parameters_return_based_on_arguments_and_values
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
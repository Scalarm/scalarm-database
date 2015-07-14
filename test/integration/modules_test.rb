require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/core/mongo_active_record'

class ModulesTest < MiniTest::Test
  include DBHelper

  def setup
    super
  end

  def teardown
    super
  end

  def test_cloud_secrets

    require 'scalarm/database/model/cloud_secrets'

    secrets = Scalarm::Database::Model::CloudSecrets.new({a: 1})

    assert_equal 1, secrets.a
  end

  def test_all_models_for_collection_name
    require 'scalarm/database/model'

    mongo_models = ((Scalarm::Database::Model.constants.collect do |c|
      Object.const_get("Scalarm::Database::Model::#{c}")
    end).select {|cls| cls < Scalarm::Database::MongoActiveRecord})

    refute_empty mongo_models

    assert mongo_models.none? {|cls| cls.collection_name.nil? }
  end

  def test_all_models_save_read
    require 'scalarm/database/model'

    mongo_models = ((Scalarm::Database::Model.constants.collect do |c|
      Object.const_get("Scalarm::Database::Model::#{c}")
    end).select {|cls| (cls < Scalarm::Database::MongoActiveRecord) and not (cls < Scalarm::Database::CappedMongoActiveRecord)})

    refute_empty mongo_models

    mongo_models.each do |model_class|
      record = model_class.new my_name: model_class.name
      record.save

      assert_equal 1, model_class.count, "Too many records in #{model_class}: #{model_class.all}"
      r_record = model_class.find_by_id(record.id)
      assert model_class.name, r_record.my_name
    end
  end

  def test_simulation_runs_for_experiments
    require 'scalarm/database/model/experiment'

    exp1 = Scalarm::Database::Model::Experiment.new(name: 'e1')
    exp1.save
    exp1.reload
    exp1.create_simulation_table

    exp2 = Scalarm::Database::Model::Experiment.new(name: 'e2')
    exp2.save
    exp2.reload
    exp2.create_simulation_table

    exp1_run_class = Scalarm::Database::SimulationRunFactory.for_experiment(exp1.id)
    exp1_run_class.new(hello: 1, world: 1).save
    exp1_run_class.new(hello: 2, world: 2).save

    exp2_run_class = Scalarm::Database::SimulationRunFactory.for_experiment(exp2.id)
    exp2_run_class.new(hello: 1, world: 3).save
    exp2_run_class.new(hello: 2, world: 4).save

    assert_equal 2, exp1.simulation_runs.count
    assert_equal 1, exp1.simulation_runs.find_by_hello(1).world
  end

  def test_simulation_run_factory
    require 'scalarm/database/simulation_run_factory'

    run_class_a = Scalarm::Database::SimulationRunFactory.for_experiment('a')
    run_class_a.new(a: 1, b: 2).save
    records_a = run_class_a.where(a: 1)
    assert_equal 1, records_a.count
    assert_equal 2, records_a.first.b

    run_class_b = Scalarm::Database::SimulationRunFactory.for_experiment('b')
    run_class_b.new(a: 1, b: 3).save
    records_b = run_class_b.where(a: 1)
    assert_equal 1, records_b.count
    assert_equal 3, records_b.first.b
  end

  def test_simulation_run
    require 'scalarm/database/simulation_run_factory'

    run_class_a = Scalarm::Database::SimulationRunFactory.for_experiment('a')
    run_class_a.create_table
  end

  def test_plgridjob
    require 'scalarm/database/model/pl_grid_job'
    j = Scalarm::Database::Model::PlGridJob.new(a: 'b')
    j.save
    assert_equal 1, Scalarm::Database::Model::PlGridJob.where(a: 'b').count
  end

end
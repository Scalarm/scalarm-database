require 'minitest/autorun'
require 'mocha/mini_test'
require_relative '../db_helper'

require 'scalarm/database/core/mongo_active_record'

class ModulesTest < MiniTest::Test
  include DBHelper

  def setup
    super

    # TODO do something with logger
    # TODO move up
    @logger_mock = stub_everything 'logger' do
      stubs(:debug)
      stubs(:info)
      stubs(:warn)
      stubs(:error)
    end
    Rails.stubs(:logger).returns(@logger_mock)
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
    end).select {|cls| cls < Scalarm::Database::MongoActiveRecord})

    refute_empty mongo_models

    mongo_models.each do |model_class|
      record = model_class.new my_name: model_class.name
      record.save

      assert_equal 1, model_class.count
      r_record = model_class.find_by_id(record.id)
      assert model_class.name, r_record.my_name
    end
  end

  # TODO - fix
  def test_simulation_runs
    require 'scalarm/database/model/experiment'

    exp1 = Scalarm::Database::Model::Experiment.new(name: 'e1')
    exp1.save
    exp1.reload

    exp1.save_simulation({one: 'two'})
    exp1.save_simulation({one: 'three'})

    exp2 = Scalarm::Database::Model::Experiment.new(name: 'e2')
    exp2.save
    exp2.reload

    exp2.save_simulation({one: 'two', two: 1})
    exp2.save_simulation({one: 'two', two: 2})

    assert_equal 1, exp1.simulation_runs.where(one: 'two').count
    assert_equal 2, exp2.simulation_runs.where(one: 'two').count
  end

end
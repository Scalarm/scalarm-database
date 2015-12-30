require_relative '../core/mongo_active_record'
require_relative '../simulation_run_factory'

require_relative '../logger'

module Scalarm::Database::Model

  ##
  # This module extends an experiment model to manage SimulationRuns
  module SimulationRunModule

    def simulation_collection_name
      "experiment_instances_#{id}" # experimental change: expriment_id -> id
    end

    def simulation_collection
      Scalarm::Database::MongoActiveRecord.get_collection(simulation_collection_name)
    end

    def create_simulation_table
      collection = simulation_collection

      raise('No Experiment Instance DB available') if collection.nil?

      collection.create_index([['index', Mongo::ASCENDING]])
      collection.create_index([['is_done', Mongo::ASCENDING]])
      collection.create_index([['to_sent', Mongo::ASCENDING]])

      # sharding collection
      cmd = BSON::OrderedHash.new
      cmd['enableSharding'] = collection.db.name
      begin
        Scalarm::Database::MongoActiveRecord.execute_raw_command_on('admin', cmd)
      rescue => e
        Scalarm::Database::Logger.error(e)
      end

      cmd = BSON::OrderedHash.new
      cmd['shardcollection'] = "#{collection.db.name}.#{simulation_collection_name}"
      cmd['key'] = {'index' => 1}
      begin
        Scalarm::Database::MongoActiveRecord.execute_raw_command_on('admin', cmd)
      rescue => e
        Scalarm::Database::Logger.error(e)
      end
    end

    def find_simulation_docs_by(query, options = { sort: [ ['index', :asc] ] })
      simulations = []

      simulation_collection.find(query, options).each{ |doc| simulations << doc }

      simulations
    end

    # Updates simulation in database
    # TODO: change method name to update_simulation?
    def save_simulation(simulation_doc)
      if simulation_doc.include?('_id')
        simulation_collection.update({'_id' => simulation_doc['_id']}, simulation_doc, {upsert: true})
      else
        simulation_collection.update({'index' => simulation_doc['index']}, simulation_doc, {upsert: true})
      end
    end

  end


  ##
  # A representation of a Scalarm's data farming experiment.
  #
  # Fields:
  #
  # [name] _string_ - user specified name
  # [description] _string_ - (optional) a longer description of the experiment
  # [is_running] _bool_ - are computations for the experiment should be made?
  # [simulation_id] _ObjectId_ - id of a simulation which is executed during the experiment
  # [user_id] _ObjectId_ - owner of the experiment
  # [time_constraint_in_sec]  _integer_ - threshold for simulation execution
  # [experiment_input] JSON structure defining parametrization of the used simulation
  #                    basically it is an extended version of a simulation input structure;
  #                    extended with information about parametrization of each parameter
  # [doe_info] information about used DoE methods - an array of triples, [ doe_method_id, array_of_parameter_ids, array_of_lists_with_values_for_each_simulation ]
  # [scheduling_policy] _string_ - policy used for generating new simulation runs (eg. monte_carlo)
  # [run_counter] _integer_ - how many times each simulation should be executed
  # [labels] (dynamic) _string_ - comma-separated list of parameter ids
  # [cached_value_list] a utilization array of values of each parameter
  # [start_at] when the experiment has been created
  # [end_at] when the user clicked “Stop”
  # [size] (cache) the number of all simulations
  # [cached_multiple_list] (cache) a list of integers generated by multiplying sizes of subsequent parameter values
  #
  # (OBSOLETE) - experiment_id: ObjectId - same as _id # TODO: check
  #
  class Experiment < Scalarm::Database::MongoActiveRecord
    require_relative 'simulation'
    require_relative 'scalarm_user'
    require_relative 'simulation_manager_temp_password'

    use_collection 'experiments'

    attr_join :simulation, Simulation
    attr_join :user, ScalarmUser

    create_index "user_id"
    create_index "simulation_id"
    create_index "is_running"
    create_index "shared_with"

    ID_DELIM = '___'

    def simulation_runs
      Scalarm::Database::SimulationRunFactory.for_experiment(id)
    end

    def simulation_manager_temp_passwords
      SimulationManagerTempPassword.where(experiment_id: id).to_a
    end

    def visible_to?(user)

    end

    def self.visible_to(user)
      where({'$or' => [{user_id: user.id}, {shared_with: {'$in' => [user.id]}}]})
    end

    def parameter_uid(entity_group, entity, parameter)
      Experiment.parameter_uid(entity_group, entity, parameter)
    end

    def self.parameter_uid(entity_group, entity, parameter)
      entity_group_id = if entity_group.include?('id') || entity_group.include?('entities')
                          entity_group['id'] || nil
                        else
                          entity_group
                        end

      entity_id = if entity.include?('id') || entity.include?('parameters')
                    entity['id'] || nil
                  else
                    entity
                  end

      parameter_id = parameter.include?('id') ? parameter['id'] : parameter

      [ entity_group_id, entity_id, parameter_id ].compact.join(ID_DELIM)
    end

    def get_parameter_ids
      parameter_ids = []

      self.experiment_input.each do |group|
        group_id = group['id']
        group['entities'].each do |entity|
          entity_id = entity['id']
          entity['parameters'].each do |parameter|
            parameter_id = parameter['id']
            parameter_ids << parameter_uid(group, entity, parameter)
          end
        end
      end

      parameter_ids
    end

  end



end

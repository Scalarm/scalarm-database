# Attributes:
#_id: id
#experiment_id: ObjectId - same as _id # TODO: check
#name: user specified name
#description: (optional) a longer description of the experiment
#is_running: bool
#simulation_id: id of a simulation which is executed during the experiment
#user_id: ObjectId
#time_constraint_in_sec: integer - threshold for simulation execution
#experiment_input: JSON structure defining parametrization of the used simulation
# - basically it is an extended version of a simulation input structure; extended with information about parametrization of each parameter
#   -  "parametrizationType" : "value",      "in_doe" : false
#doe_info: information about used DoE methods - an array of triples, [ doe_method_id, array_of_parameter_ids, array_of_lists_with_values_for_each_simulation ]
#scheduling_policy: string -
#run_counter: integer - how many times each simulation should be executed
#labels: (dynamic) string - concatenated list of parameter ids
#“cached_value_list”: a utilization array of values of each parameter
#“start_at”: when the experiment has been created
#“end_at”: when the user clicked “Stop”
#“size”: (cache) the number of all simulations
#“cached_multiple_list”: (cache) a list of integers generated by multiplying sizes of subsequent parameter values

require_relative '../core/mongo_active_record'
require_relative '../simulation_run_factory'

require_relative '../logger'

require_relative 'simulation'

module Scalarm::Database::Model

  #Attributes:
  #“_id”: ObjectId
  #“index”: integer
  #“experiment_id” - ObjectId # TODO: check
  #“to_sent” - bool
  #“sent_at”: timestamp
  #“is_done”: bool
  #“done_at”: timestamp
  #“run_index”: integer
  #“arguments”: string - list of concatenated parameter ids
  #“values”: string - list of concatenated parameter values
  #“result”: JSON structure generated by simulation
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

  class Experiment < Scalarm::Database::MongoActiveRecord
    use_collection 'experiments'

    attr_join :simulation, Simulation
    attr_join :user, ScalarmUser

    def simulation_runs
      Scalarm::Database::SimulationRunFactory.for_experiment(id)
    end

  end



end

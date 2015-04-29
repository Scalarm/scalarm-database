require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class SimulationExecutor < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_executors'
  end
end

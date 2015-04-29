require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class SimulationInputWriter < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_input_writers'
  end
end

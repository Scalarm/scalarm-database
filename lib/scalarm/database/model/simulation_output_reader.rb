require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class SimulationOutputReader < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_output_readers'
  end
end

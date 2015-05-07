require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Represents output reader adapter.
  # ==== Fields:
  # user_id:: owner
  # name:: name
  # code:: script code
  #
  class SimulationOutputReader < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_output_readers'
  end
end

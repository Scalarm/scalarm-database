require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Represents executor adapter.
  # ==== Fields:
  # user_id:: owner
  # name:: name
  # code:: script code
  #
  class SimulationExecutor < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_executors'
  end
end

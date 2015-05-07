require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Represents progress monitor adapter.
  # ==== Fields:
  # user_id:: owner
  # name:: name
  # code:: script code
  #
  class SimulationProgressMonitor < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_progress_monitors'
  end
end

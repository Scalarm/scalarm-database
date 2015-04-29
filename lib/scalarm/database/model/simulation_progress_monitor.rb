require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class SimulationProgressMonitor < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_progress_monitors'
  end
end

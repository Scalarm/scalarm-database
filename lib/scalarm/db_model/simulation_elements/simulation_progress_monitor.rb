require 'scalarm/db_model/core/mongo_active_record'

module Scalarm
  module DbModel
    class SimulationProgressMonitor < MongoActiveRecord

      def self.collection_name
        'simulation_progress_monitors'
      end

    end
  end
end
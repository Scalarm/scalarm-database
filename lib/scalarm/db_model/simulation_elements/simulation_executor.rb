require 'scalarm/db_model/core/mongo_active_record'

module Scalarm
  module DbModel
    class SimulationExecutor < MongoActiveRecord

      def self.collection_name
        'simulation_executors'
      end

    end
  end
end


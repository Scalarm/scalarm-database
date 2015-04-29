require 'scalarm/db_model/core/mongo_active_record'

module Scalarm
  module DbModel
    class SimulationInputWriter < MongoActiveRecord

      def self.collection_name
        'simulation_input_writers'
      end

    end
  end
end

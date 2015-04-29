require 'scalarm/db_model/core/mongo_active_record'

module Scalarm
  module DbModel
    class SimulationOutputReader < MongoActiveRecord

      def self.collection_name
        'simulation_output_readers'
      end

    end
  end
end
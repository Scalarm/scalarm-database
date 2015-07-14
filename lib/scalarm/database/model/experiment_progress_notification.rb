require 'scalarm/database/core/capped_mongo_active_record'

module Scalarm
  module Database
    module Model
      ##
      # A capped collection used for gathering information about experiment progress changes
      class ExperimentProgressNotification < Scalarm::Database::CappedMongoActiveRecord
        use_collection 'experiment_progress_notifications'

        def self.capped_size
          1048576
        end

        def self.capped_max
          50000
        end

      end
    end
  end
end
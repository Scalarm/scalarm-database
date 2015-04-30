require_relative 'core/mongo_active_record'
require_relative 'logger'

module Scalarm::Database

  # Allows to create SimulationRun model (class) dedicated for specific Experiment
  class SimulationRunFactory

    def self.collection_name_for(experiment_id)
      "experiment_instances_#{experiment_id}"
    end

    def self.for_experiment(experiment_id)
      Class.new(Scalarm::Database::MongoActiveRecord) do |c|
        use_collection SimulationRunFactory.collection_name_for(experiment_id)

        def where(conditions, options)
          super(conditions, {sort: [['index', :asc]]}.merge(options))
        end

        def self.create_table
          raise('No Simulation Run DB available') if collection.nil?

          %w(index is_done to_sent).each do |index_sym|
            unless collection.index_information.include?(index_sym.to_s)
              collection.create_index([[index_sym.to_s, Mongo::ASCENDING]])
            end
          end

          # sharding collection
          cmd = BSON::OrderedHash.new
          cmd['enableSharding'] = collection.db.name
          begin
            MongoActiveRecord.execute_raw_command_on('admin', cmd)
          rescue => e
            Logger.error(e)
          end

          cmd = BSON::OrderedHash.new
          cmd['shardcollection'] = "#{collection.db.name}.#{collection_name}"
          cmd['key'] = {'index' => 1}
          begin
            MongoActiveRecord.execute_raw_command_on('admin', cmd)
          rescue => e
            Logger.error(e)
          end
        end

      end

    end
  end
end
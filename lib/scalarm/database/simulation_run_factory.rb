require_relative 'core/mongo_active_record'
require_relative 'logger'

module Scalarm::Database

  # Can be applied only for MongoActiveRecord classes
  module SimulationRun
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

    def meet_constraints?(constraints)
      return true if constraints.blank?

      args = arguments.split(',')
      vals = values.split(',')
      constraints.each do |constraint|
        source_value = vals[args.index(constraint['source_parameter'])].to_f
        target_value = vals[args.index(constraint['target_parameter'])].to_f
        #Rails.logger.debug("Checking if #{source_value} #{constraint['condition']} #{target_value}")
        unless source_value.send(constraint['condition'], target_value)
          return false
        end
      end

      true
    end

  end

  # Allows to create SimulationRun model (class) dedicated for specific Experiment
  class SimulationRunFactory
    def self.for_experiment(experiment_id)
      Class.new(Scalarm::Database::MongoActiveRecord) do |c|
        include SimulationRun

        def self.collection_name_for(experiment_id)
          "experiment_instances_#{experiment_id}"
        end

        use_collection collection_name_for(experiment_id)
        attr_join :experiment, Experiment
      end
    end
  end
end
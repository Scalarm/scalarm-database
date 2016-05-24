require 'scalarm/database/core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Represents a simulation scenario - entity describing parameters of simulation,
  # files of simulation and adapters (wrapper scripts).
  #
  # ==== Fields:
  #
  # name::
  # description::
  # input_specification::
  # user_id::
  # simulation_binaries_id::
  # input_writer_id::
  # executor_id::
  # output_reader_id::
  # progress_monitor_id::
  # created_at:: timestamp
  class Simulation < Scalarm::Database::MongoActiveRecord
    require_relative 'scalarm_user'
    require_relative 'simulation_executor'
    require_relative 'simulation_input_writer'
    require_relative 'simulation_output_reader'
    require_relative 'simulation_progress_monitor'
    require_relative 'experiment'

    use_collection 'simulations'

    # TODO: when all data in base will be migrated to json-only, this will be unnecessarily
    parse_json_if_string 'input_specification'

    attr_join :user, ScalarmUser
    attr_join :input_writer, SimulationInputWriter
    attr_join :executor, SimulationExecutor
    attr_join :output_reader, SimulationOutputReader
    attr_join :progress_monitor, SimulationProgressMonitor

    create_index({user_id: 1, name: 1})

    def set_simulation_binaries(filename, binary_data)
      file = Grid::File.new(binary_data, filename: filename, metadata: { size: binary_data.size })
      @attributes['simulation_binaries_id'] = @@binary_store.insert_one(file).to_s
    end

    def simulation_binaries
      file = @@binary_store.find_one(_id: self.simulation_binaries_id)
      if file.nil?
        nil
      else
        file.data
      end
    end

    def simulation_binaries_name
      file = @@binary_store.find_one(_id: self.simulation_binaries_id)
      if file.nil?
        nil
      else
        file.info.filename
      end
    end

    def simulation_binaries_size
      file = @@binary_store.find_one(_id: self.simulation_binaries_id)
      if file.nil?
        nil
      else
        metadata = file.info.metadata
        if metadata.has_key?("size")
          metadata["size"]
        else
          file.data.size
        end
      end
    end

    def destroy
      begin
        @@binary_store.delete(self.simulation_binaries_id)
      rescue => e
        # if there is no file with this id then it is ok
      end

      super
    end

    def input_parameters
      parameters = {}

      self.input_specification.each do |group|
        group['entities'].each do |entity|
          entity['parameters'].each do |parameter|
            param_uid = Experiment.parameter_uid(group, entity, parameter)
            parameters[param_uid] = input_parameter_label_for(param_uid)
          end
        end
      end

      parameters
    end

    def input_parameter_label_for(uid)
      split_uid = uid.split(Experiment::ID_DELIM)
      entity_group_id, entity_id, parameter_id = split_uid[-3], split_uid[-2], split_uid[-1]

      self.input_specification.each do |entity_group|
        if entity_group['id'] == entity_group_id
          entity_group['entities'].each do |entity|
            if entity['id'] == entity_id
              entity['parameters'].each do |parameter|
                if parameter['id'] == parameter_id
                  return [ entity_group['label'], entity['label'], parameter['label'] ].compact.join(" - ")
                end
              end
            end
          end
        end
      end

      nil
    end

    def self.visible_to(user)
      where({'$or' => [{user_id: user.id}, {shared_with: {'$in' => [user.id]}}, {is_public: true}]})
    end

  end
end

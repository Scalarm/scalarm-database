require_relative '../core/mongo_active_record'

require_relative 'private_machine_credentials'
require_relative 'experiment'

module Scalarm::Database::Model

  ##
  # Represents SimulationManager working as a process on some private resource
  # ==== Fields:
  # credentials_id:: id of PrivateMachineCredentials
  # pid:: PID of SimulationManager process executed at remote machine
  # ppn:: number of cores on the machine
  class PrivateMachineRecord < Scalarm::Database::MongoActiveRecord
    # SimulationManagerRecord
    use_collection 'private_machine_records'

    attr_join :credentials, PrivateMachineCredentials
    attr_join :experiment, Experiment

    disable_ids_auto_convert!

  end
end


require 'securerandom'

require_relative '../core/mongo_active_record'
require_relative 'experiment'
require_relative 'scalarm_user'

module Scalarm::Database::Model

  ##
  # A temporary credentials to access Scalarm.
  # Generated for SimulationManager and WorkersManager to give them temporary access.
  # These credentials are used for basic auth authentication.
  # ==== Fields:
  # sm_uuid:: string - uuid which identifies a simulation manager - also can be used as a user
  # password:: password of the attached simulation manager
  # experiment_id:: id of an experiment which should be calculated by Simulation Manager with this temp password
  class SimulationManagerTempPassword < Scalarm::Database::MongoActiveRecord
    use_collection 'simulation_manager_temp_passwords'
    # TODO attr_join by const
    # attr_join :experiment, Experiment

    create_index "experiment_id"
    create_index "sm_uuid"
    create_index "user_id"

    def self.create_new_password_for(sm_uuid, experiment_id)
      password = SecureRandom.base64
      temp_pass = self.new(sm_uuid: sm_uuid,
                           password: password,
                           experiment_id: experiment_id)
      temp_pass.save
      temp_pass
    end

    def scalarm_user
      if self.user_id.nil?

        if self.experiment_id.nil?
          nil
        else
          ScalarmUser.find_by_id(Experiment.find_by_id(self.experiment_id).user_id)
        end

      else
        ScalarmUser.find_by_id(self.user_id)
      end
    end

  end
end


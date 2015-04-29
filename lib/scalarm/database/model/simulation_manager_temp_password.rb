# Attributes
# sm_uuid => string - uuid which identifies a simulation manager - also can be used as user
# password => password of the attached simulation manager
# experiment_id => id of an experiment which should be calculated by Simulation Manager with this temp password

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class SimulationManagerTempPassword < Scalarm::Database::MongoActiveRecord

    attr_join :experiment, Experiment

    def self.collection_name
      'simulation_manager_temp_passwords'
    end

    def self.create_new_password_for(sm_uuid, experiment_id)
      password = SecureRandom.base64
      temp_pass = SimulationManagerTempPassword.new(sm_uuid: sm_uuid,
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


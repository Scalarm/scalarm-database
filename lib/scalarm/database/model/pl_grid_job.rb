require_relative '../core/mongo_active_record'
require_relative 'experiment'
require_relative 'grid_credentials'

module Scalarm::Database::Model

  ##
  # Represents job in any of PL-Grid resources manager.
  # ==== Fields:
  # job_identifier:: string - queue system specific id of the job
  # scheduler_type:: string - short name of scheduler, eg. pbs
  # grant_identifier::
  # nodes:: nodes count
  # ppn:: cores per node count
  # plgrid_host:: host of PL-Grid, eg. zeus.cyfronet.pl
  #
  # Note that some attributes are used only by some queuing system facades
  class PlGridJob < Scalarm::Database::MongoActiveRecord
    # SimulationManagerRecord

    use_collection 'grid_jobs'

    attr_join :experiment, Experiment

    def credentials
      @credentials ||= GridCredentials.where(user_id: user_id).first
    end

    def to_s
      "JobId: #{job_identifier}, Scheduled at: #{created_at}, ExperimentId: #{experiment_id}"
    end

  end
end


# Specific attributes:
# job_id => string - queue system specific id of the job
# scheduler_type => string - short name of scheduler, eg. pbs
# grant_id
# nodes - nodes count
# ppn - cores per node count
# plgrid_host - host of PL-Grid, eg. zeus.cyfronet.pl
#
# Note that some attributes are used only by some queuing system facades

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class PlGridJob < Scalarm::Database::MongoActiveRecord
    # SimulationManagerRecord

    use_collection 'grid_jobs'
    disable_ids_auto_convert!

    attr_join :experiment, Experiment

    def credentials
      @credentials ||= GridCredentials.find_by_user_id(user_id)
    end

    def resource_id
      self.job_id
    end

    def to_s
      "JobId: #{job_id}, Scheduled at: #{created_at}, ExperimentId: #{experiment_id}"
    end

  end
end


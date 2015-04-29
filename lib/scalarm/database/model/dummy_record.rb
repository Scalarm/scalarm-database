# SimulationManagerRecord Class for Dummy Infrastructure used for various tests.
#
# Fields:
# * fields from SimulationManagerRecords
# - res_id

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class DummyRecord < Scalarm::Database::MongoActiveRecord
    use_collection 'dummy_records'
  end
end

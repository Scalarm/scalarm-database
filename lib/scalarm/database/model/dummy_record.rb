require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # SimulationManagerRecord Class for Dummy Infrastructure used for various tests.
  #
  # ==== Fields:
  # Contains fields from SimulationManagerRecords
  #
  # res_name:: string - a dummy resource identifier
  class DummyRecord < Scalarm::Database::MongoActiveRecord
    use_collection 'dummy_records'
  end
end

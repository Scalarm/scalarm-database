# SimulationManagerRecord Class for Dummy Infrastructure used for various tests.
#
# Fields:
# * fields from SimulationManagerRecords
# - res_id

module Scalarm
  module DbModel
    class DummyRecord < MongoActiveRecord
      use_collection 'dummy_records'
    end
  end
end

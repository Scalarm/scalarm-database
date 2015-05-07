require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Record in database indicating distributed lock
  #
  # ==== Fields:
  # name:: _string_ name of lock, allowing to use multiple locks
  # global_pid::  _string_ globally uniqe identifier of thread that set the lock;
  #               format: <host_name_or_ip>_<pid>_<thread_id>
  class MongoLockRecord < Scalarm::Database::MongoActiveRecord
    def self.collection_name
      'mongo_locks'
    end
  end
end

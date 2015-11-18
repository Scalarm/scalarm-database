require 'securerandom'

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Stores information about browser session.
  # Single user can have multiple sessions.
  # ==== Fields:
  # session_id:: the same as id of ScalarmUser which owns the session
  # uuid:: unique session id used for distinct muliple sessions for single user
  # last_update:: timestamp of last authentication made with this session
  class UserSession < Scalarm::Database::MongoActiveRecord
    use_collection 'users_session'
  end
end

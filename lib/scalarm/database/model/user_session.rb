require 'securerandom'

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class UserSession < Scalarm::Database::MongoActiveRecord
    use_collection 'users_session'
    disable_ids_auto_convert!
  end
end

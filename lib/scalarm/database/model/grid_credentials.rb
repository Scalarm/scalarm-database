require 'base64'

require_relative '../core'

require_relative 'scalarm_user'
require_relative 'grid_credentials'

module Scalarm::Database::Model

  ##
  # Store credentials used for PL-Grid access
  #
  # ==== Fields:
  # user_id:: Scalarm's owner of credentials
  # login:: PL-Grid user name (same as in PL-Grid Portal and on UI machines)
  # password:: (not needed if has secret_proxy)
  # secret_proxy:: (not needed if has password)
  class GridCredentials < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'grid_credentials'
    attr_join :user, ScalarmUser

    create_index "user_id"

    # Exclude also hashed password field
    def to_h
      super.select {|k, v| k != 'hashed_password'}
    end

  end
end



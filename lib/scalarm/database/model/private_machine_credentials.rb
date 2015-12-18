require_relative '../core/encrypted_mongo_active_record'

require_relative 'scalarm_user'

module Scalarm::Database::Model

  ##
  # ==== Fields:
  # host:: ip/dns address of the machine
  # port::
  # user_id:: ScalarmUser id who has this secrets
  #
  # login:: ssh login
  # secret_password:: ssh password
  #
  # Other fields are user defined and should be of String class to enable encryption!
  class PrivateMachineCredentials < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'private_machine_credentials'

    attr_join :user, ScalarmUser

    create_index({user_id: 1, host: 1})

    def machine_desc
      "#{login}@#{host}:#{port}"
    end

  end
end


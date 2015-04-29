# Fields:
# host: ip/dns address of the machine
# port
# user_id: ScalarmUser id who has this secrets
#
# login: ssh login
# secret_password: ssh password
#
# other fields are user defined and should be of String class to enable encryption!

require_relative '../core/encrypted_mongo_active_record'

module Scalarm::Database::Model
  class PrivateMachineCredentials < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'private_machine_credentials'

    attr_join :user, ScalarmUser

    def machine_desc
      "#{login}@#{host}:#{port}"
    end

  end
end


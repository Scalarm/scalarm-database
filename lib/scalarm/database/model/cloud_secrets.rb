require_relative '../core/encrypted_mongo_active_record'

require_relative 'scalarm_user'

module Scalarm::Database::Model

    ##
    # Credentials needed to access cloud service (e.g. cloud API user/password)
    #
    # ==== Fields:
    # cloud_name:: string - cloud name, e.g. 'amazon'
    # user_id:: ObjectId - ScalarmUser id who has this secrets
    #
    # other fields are user defined and should be of String class to enable encryption!
    class CloudSecrets < Scalarm::Database::EncryptedMongoActiveRecord
      use_collection 'cloud_secrets'
      attr_join :user, ScalarmUser

      create_index({cloud_name: 1, user_id: 1})
    end
end

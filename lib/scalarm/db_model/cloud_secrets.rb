# Credentials needed to access cloud service (e.g. cloud API user/password)
#
# Fields:
# - cloud_name: string - cloud name, e.g. 'amazon'
# - user_id: ScalarmUser id who has this secrets
#
# other fields are user defined and should be of String class to enable encryption!

module Scalarm
  module DbModel
    class CloudSecrets < EncryptedMongoActiveRecord
      use_collection 'cloud_secrets'
      attr_join :user, ScalarmUser
    end
  end
end

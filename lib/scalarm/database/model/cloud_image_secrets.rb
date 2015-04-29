# Stores information and credentials needed to instantiate cloud image
# and access its instance.
#
# Fields:
# - user_id => ScalarmUser id
# - image_id: string => id of image in Cloud
# - experiment_id => DataFarmingExperiment id
# - cloud_name: string => one of Cloud short names, e.g. 'pl_cloud', 'amazon'
#
# other fields are cloud-specific, e.g. image_login, secret_password, secret_token

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class CloudImageSecrets < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'cloud_image_secrets'
    attr_join :user, ScalarmUser
  end
end

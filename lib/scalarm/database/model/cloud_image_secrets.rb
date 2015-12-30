require_relative '../core/mongo_active_record'

require_relative 'scalarm_user'

module Scalarm::Database::Model

  ##
  # Stores information and credentials needed to instantiate cloud image
  # and access its instance.
  #
  # ==== Fields:
  # user_id:: _ObjectId_ - ScalarmUser id
  # image_identifier:: _string_ - id of image in Cloud
  # experiment_id:: _ObjectId_ - DataFarmingExperiment id
  # cloud_name::  _string_ - cloud service identifier;
  #               one of Cloud short names, e.g. 'pl_cloud', 'amazon'
  #
  # other fields are cloud-specific, e.g. image_login, secret_password, secret_token
  class CloudImageSecrets < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'cloud_image_secrets'
    attr_join :user, ScalarmUser

    create_index({user_id: 1, cloud_name: 1})
  end
end

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # Stores information and credentials needed to instantiate cloud image
  # and access its instance.
  #
  # ==== Fields:
  # user_id:: _ObjectId_ - ScalarmUser id
  # image_id:: _string_ - id of image in Cloud (NOTE: not a foreign-key!)
  # experiment_id:: _ObjectId_ - DataFarmingExperiment id
  # cloud_name::  _string_ - cloud service identifier;
  #               one of Cloud short names, e.g. 'pl_cloud', 'amazon'
  #
  # other fields are cloud-specific, e.g. image_login, secret_password, secret_token
  class CloudImageSecrets < Scalarm::Database::EncryptedMongoActiveRecord
    use_collection 'cloud_image_secrets'
    attr_join :user, ScalarmUser
  end
end

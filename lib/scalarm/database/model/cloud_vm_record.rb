require_relative '../core/mongo_active_record'

require_relative 'cloud_secrets'
require_relative 'cloud_image_secrets'

module Scalarm::Database::Model

  ##
  # Binds Scalarm user, experiment and cloud virtual machine instance
  # providing static information about VM instance (set once)
  #
  # ==== Fields:
  # Contains fields from SimulationManagerRecords
  #
  # cloud_name:: string - name of the cloud, e.g. 'pl_cloud', 'amazon'
  # image_secrets_id:: ObjectId - id of CloudImageSecrets;
  #     a foreign key to access information about image that was instatiated
  # vm_identifier:: string - instance id of the vm
  # pid:: integer - PID of SimulationManager application (if executed)
  # instance_type:: string - name of instance type
  #
  # public_host: string - public hostname of machine which redirects to ssh port
  # public_ssh_port: string - port of public machine redirecting to ssh private port
  class CloudVmRecord < Scalarm::Database::MongoActiveRecord
    use_collection 'vm_records'

    attr_join :image_secrets, CloudImageSecrets

    def cloud_secrets
      @cloud_secrets ||= CloudSecrets.where(cloud_name: cloud_name.to_s, user_id: user_id.to_s).first
    end

    # additional info for specific cloud should be provided by CloudClient
    def to_s
      "Id: #{vm_identifier}, Launched at: #{created_at}, Time limit: #{time_limit}, "
      "SSH address: #{public_host}:#{public_ssh_port}"
    end
  end
end


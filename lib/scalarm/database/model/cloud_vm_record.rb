# Binds Scalarm user, experiment and cloud virtual machine instance
# providing static information about VM instance (set once)
#
# Fields:
# * fields from SimulationManagerRecords
#
# - cloud_name => string - name of the cloud, e.g. 'pl_cloud', 'amazon'
# - image_secrets_id => id of CloudImageSecrets
# - vm_id => string - instance id of the vm
# - pid => integer - PID of SimulationManager application (if executed)
# - instance_type => string - name of instance type
#
# - public_host => public hostname of machine which redirects to ssh port
# - public_ssh_port => port of public machine redirecting to ssh private port

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class CloudVmRecord < Scalarm::Database::MongoActiveRecord
    use_collection 'vm_records'
    disable_ids_auto_convert!

    attr_join :image_secrets, CloudImageSecrets

    def cloud_secrets
      @cloud_secrets ||= CloudSecrets.find_by_query(cloud_name: cloud_name.to_s, user_id: user_id.to_s)
    end

    # additional info for specific cloud should be provided by CloudClient
    def to_s
      "Id: #{vm_id}, Launched at: #{created_at}, Time limit: #{time_limit}, "
      "SSH address: #{public_host}:#{public_ssh_port}"
    end
  end
end


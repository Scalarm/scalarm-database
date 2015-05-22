module Scalarm::Database
  module Utils
    def self.parse_json_if_string(value)
      value.kind_of?(String) and JSON.parse(value) or value
    end
  
    def self.to_bson_if_string(object_id)
      object_id.kind_of?(String) ? BSON::ObjectId(object_id) : object_id
    end
  end
end

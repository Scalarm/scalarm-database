# Attributes
# _id => auto generated user id
# dn => distinguished user name from certificate
# login => last CN attribute value from dn

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model
  class ScalarmUser < Scalarm::Database::MongoActiveRecord
    use_collection 'scalarm_users'

    def password=(pass)
      salt = [Array.new(6) { rand(256).chr }.join].pack('m').chomp
      self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
    end

  end
end

require_relative '../core/mongo_active_record'

module Scalarm::Database::Model

  ##
  # A Scalarm's application user.
  # ==== Fields:
  # dn:: distinguished user name from certificate
  # login:: last CN attribute value from dn
  #
  class ScalarmUser < Scalarm::Database::MongoActiveRecord
    use_collection 'scalarm_users'

    ##
    # A setter for a user password, it stores only password digest,
    # so original password cannot be restored.
    def password=(pass)
      salt = [Array.new(6) { rand(256).chr }.join].pack('m').chomp
      self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
    end

  end
end

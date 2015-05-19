require 'base64'

require_relative '../core'

require_relative 'scalarm_user'
require_relative 'grid_credentials'

module Scalarm::Database::Model

  ##
  # Store credentials used for PL-Grid access
  #
  # ==== Fields:
  # user_id:: Scalarm's owner of credentials
  # login:: PL-Grid user name (same as in PL-Grid Portal and on UI machines)
  # password:: (not needed if has secret_proxy)
  # secret_proxy:: (not needed if has password)
  class GridCredentials < Scalarm::Database::MongoActiveRecord
    @@CIPHER_NAME = 'aes-256-cbc'
    @@CIPHER_KEY = "tC\x7F\x9Er\xA6\xAFU\x88\x19\x9B\x0F\xDD\x88O]6\xA0\xAD\x8B\xBF,4\x06<\xC0[\x03\xC7\x11\x90\x10"
    @@CIPHER_IV = "\xA9\x8E\xD0\x031 w0\x1Ed\xEC\xC4\xD4\xEA\x87\e"

    use_collection 'grid_credentials'
    attr_join :user, ScalarmUser

    def password
      if hashed_password
        decipher = GridCredentials::decipher
        password = decipher.update(Base64.strict_decode64(self.hashed_password))
        password << decipher.final

        password
      else
        nil
      end
    end

    def password=(new_password)
      cipher = GridCredentials::cipher
      encrypted_password = cipher.update(new_password)
      encrypted_password << cipher.final
      encrypted_password = Base64.strict_encode64(encrypted_password)

      self.hashed_password = encrypted_password
    end

    # Exclude also hashed password field
    def to_h
      super.select {|k, v| k != 'hashed_password'}
    end

    def self.cipher
      cipher = OpenSSL::Cipher::Cipher.new(@@CIPHER_NAME)
      cipher.encrypt
      cipher.padding = 1
      cipher.key = @@CIPHER_KEY
      cipher.iv = @@CIPHER_IV

      cipher
    end

    def self.decipher
      decipher = OpenSSL::Cipher::Cipher.new(@@CIPHER_NAME)
      decipher.decrypt
      decipher.key = @@CIPHER_KEY
      decipher.iv = @@CIPHER_IV

      decipher
    end

  end
end



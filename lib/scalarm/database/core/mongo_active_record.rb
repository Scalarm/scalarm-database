require 'bson'
require 'mongo'
require 'json'
require 'active_support/core_ext/object/deep_dup'
require 'encryptor'

require_relative 'mongo_active_record_utils'
require_relative '../logger'

module Scalarm
  module Database
    class MongoActiveRecord
      include Mongo
      include MongoActiveRecordUtils

      attr_reader :attributes

      @conditions = {}
      @options = {}
      @@client = nil

      class << self
        attr_accessor :_indexed_attributes
      end
      @_indexed_attributes = []

      def self.ids_auto_convert
        true
      end

      def self.conditions
        @conditions
      end

      def self.conditions=(conds)
        @conditions = conds
      end

      def self.options
        @options
      end

      def self.options=(opts)
        @options = opts
      end

      def self.available?
        begin
          self.get_collection('test').find.first
          return true
        rescue
          return false
        end
      end

      def self.execute_raw_command_on(db, cmd)
        @@db.connection.db(db).command(cmd)
      end

      def self.get_collection(collection_name)
        @@db[collection_name]
      end

      # object instance constructor based on map of attributes (json document is good example)
      def initialize(attributes)
        @attributes = {}

        attributes.each do |parameter_name, parameter_value|
          parameter_name = parameter_name.to_s
          if parameter_name.end_with?('_id') and parameter_value.kind_of?(String)
            parameter_value = BSON::ObjectId(parameter_value) rescue parameter_value
          end
          @attributes[parameter_name] = parameter_value
        end
      end

      # handling getters and setters for object instance
      def method_missing(method_name, *args, &block)
        method_name = method_name.to_s; setter = false
        if method_name.end_with? '='
          method_name.chop!
          setter = true
        end

        method_name = '_id' if method_name == 'id'

        if setter
          set_attribute(method_name, args.first)
        elsif attributes.include?(method_name)
          get_attribute(method_name)
        else
          nil
          #super(method_name, *args, &block)
        end
      end

      def set_attribute(attribute, value)
        value = BSON::ObjectId(value) rescue value if attribute.end_with?('_id') and value.kind_of?(String)
        @attributes[attribute] = value
      end

      def get_attribute(attribute)
        value = attributes[attribute]
        if attribute.end_with?('_id') and value.kind_of?(String)
          BSON::ObjectId(value) rescue value
        else
          value
        end
      end

      def _delete_attribute(attribute)
        @attributes.delete(attribute)
      end

      # save/update json document in db based on attributes
      # if this is new object instance - _id attribute will be added to attributes
      def save
        if @attributes.include? '_id'
          self.class.collection.update_one({'_id' => @attributes['_id']}, @attributes, {upsert: true})
        else
          insert_result = self.class.collection.insert_one(@attributes)
          if not insert_result.nil?
            @attributes['_id'] = insert_result.inserted_id
          end
        end
        self
      end

      def save_if_exists
        self.save if self.class.find_by_id(self.id)
      end

      def destroy
        return if not @attributes.include? '_id'

        self.class.collection.delete_one({ '_id' => @attributes['_id'] })
        @attributes.delete('_id')
      end

      def reload
        @attributes = self.class.find_by_query(id: self.id).attributes
        self
      end

      def to_s
        if self.nil?
          'Nil'
        else
          <<-eos
      MongoActiveRecord - #{self.class.name} - Attributes - #{@attributes}\n
          eos
        end
      end

      def to_h
        Hash[attributes.keys.map do |key|
               value = self.send(key)
               [key, (value.kind_of?(BSON::ObjectId) ? value.to_s : value)]
             end]
      end

      def to_json
        to_h.to_json
      end

      ##
      # Converts this object to object of MongoActiveRecord class "record_class"
      # by copying attributes.
      def convert_to(record_class)
        record_class.new(self.attributes)
      end


      #### Class Methods ####

      def self.connected?
        !@@client.nil?
      end

      def self.collection_name
        raise 'This is an abstract method, which must be implemented by all subclasses'
      end

      # returns a reference to mongo collection based on collection_name abstract method
      def self.collection
        class_collection = @@db[self.collection_name]
        raise "Error while connecting to #{self.collection_name}" if class_collection.nil?

        class_collection
      end

      # find by dynamic methods
      def self.method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?('find_by')
          parameter_name = method_name.to_s.split('_')[2..-1].join('_')

          return self.find_by(parameter_name, args)

        elsif method_name.to_s.start_with?('find_all_by')
          parameter_name = method_name.to_s.split('_')[3..-1].join('_')

          return self.find_all_by(parameter_name, args)

        elsif (not instance_methods.include?(method_name.to_sym)) and (Array.instance_methods.include?(method_name.to_sym))

          return to_a.send(method_name.to_sym, *args, &block)
        end

        super(method_name, *args, &block)
      end

      def self.all
        where({}, {}).to_a
      end

      def self.destroy(selector)
        self.collection.delete_many(selector)
      end

      def self.find_by_query(query)
        self.where(query, {limit: 1}).first
      end

      def self.find_all_by_query(query, opts = {})
        self.where(query, opts).to_a
      end

      def self.find_by(parameter, value)
        value = value.first if value.is_a? Enumerable
        self.find_by_query(parameter => value)
      end

      def self.find_all_by(parameter, value)
        value = value.first if value.is_a? Enumerable
        self.find_all_by_query(parameter => value)
      end

      ##
      # Get Mongo database onbject only if MongoActiveRecord
      # was initialized earlier with connection_init.
      # If connection_init was invoked with username and password,
      # these values will be used to authenticate to this db.
      # Use nil to override and force disable authetication for this db.
      # @param [String] db_name database name to get
      # @param [String] username optional username to authenticate
      # @param [String] password optional password to authenticate
      def self.get_database(db_name, username=@@username, password=@@password)
        if @@client.nil?
          nil
        else
          current_db = @@client.database.name

          db = @@client.use(db_name).database
          if username and password and not db_authenticated?(db_name)
            db.authenticate(username, password)
          end

          @@client.use(current_db)

          db
        end
      end

      def self.db_authenticated?(db_name)
        not (@@client.auths.select {|a| a[:db_name] == db_name }).empty?
      end

      # chaining capabilities
      def self.where(cond, opts = {})
        mongo_class = self.deep_dup
        mongo_class.conditions = @conditions.deep_dup || {}
        mongo_class.options = @options.deep_dup || {}

        cond.each do |key, value|
          key = key.to_sym
          key = :_id if key == :id

          if key == :_id
            value = BSON::ObjectId(value.to_s)
          elsif key.to_s.end_with?('_id') and self.ids_auto_convert
            # some ugly hack - if ID can be converted to BSON (or is BSON) use both String and BSON in query
            # otherwise, use only stringified value
            bson_value = begin
              Utils::to_bson_if_string(value)
            rescue BSON::InvalidObjectId
              nil
            end

            str_value = value.to_s
            if bson_value
              value = {'$in' => [str_value, bson_value]}
            else
              value = str_value
            end
          end

          mongo_class.conditions[key] = value
        end

        mongo_class.options.merge! opts

        mongo_class
      end

      def self.to_a
        results = self.collection.find(@conditions || {}, @options || {}).map do |attributes|
          self.new(attributes)
        end

        @conditions = {}; @options = {}

        results
      end

      def self.size
        count
      end

      def self.count
        results = self.collection.count(@conditions || {})

        @conditions = {}; @options = {}

        results
      end

      # INITIALIZATION STUFF

      ##
      # Backward-compatible alias for connection_init
      def self.init!(*args)
        connection_init(*args)
      end

      ##
      # Initializes global connection for MongoActiveRecords and sets default database
      # to use with MongoActiveRecord instances
      # @param [String] mongodb_address host:port of mongodb server
      # @param [String] db_name name of database (often it's "scalarm_db")
      # @param [Hash] options additional params: Symbol => Object
      #  - username: username to use if using authentication; leave nil to disable auth
      #  - password: password to use if using authentication; leave nit to disable auth
      #  - connect_timeout: MongoClient connect_timeout option, default: 15.0
      #  - pool_size: MongoClient pool_size option, default: 12
      #  - pool_timeout: MongoClient pool_timeout_option, default: 30.0
      def self.connection_init(mongodb_address, db_name, options=nil)
        options ||= {}
        username = options[:username]
        password = options[:password]
        connect_timeout = options[:connect_timeout] || 15.0
        pool_size = options[:pool_size] || 12
        pool_timeout = options[:pool_timeout] || 30.0

        begin
          Logger.debug("MongoActiveRecord initialized with URL '#{mongodb_address}' and DB '#{db_name}'")
          Mongo::Logger.logger = Logger

          @@username = username
          @@password = password

          @@client = Client.new( [mongodb_address],
                                 database: db_name,
                                 user: username,
                                 password: password,
                                 connect_timeout: connect_timeout,
                                 min_pool_size: pool_size,
                                 max_pool_size: 2*pool_size,
                                 wait_queue_timeout: pool_timeout
          )

          @@db = @@client.database
          @@binary_store = @@db.fs

          return true
        rescue => e
          Logger.debug "Could not initialize connection with MongoDB --- #{e}"
          @@client = @@db = @@binary_store = nil

          # changed Scalarm::ServiceCore: connection_init failure is fatal
          raise
        end

        false
      end

      def self.set_encryption_key(key)
        Encryptor.default_options.merge!(key: key)
      end

      # UTILS

      def self.next_sequence
        self.get_next_sequence(self.collection_name)
      end

      def self.get_next_sequence(name)
        collection = MongoActiveRecord.get_collection('counters')
        doc = collection.find_one_and_update({ _id: name }, { "$inc" => { seq: 1 }}, upsert: true)

        if doc.nil?
          doc = collection.find_one_and_update({ _id: name }, { "$inc" => { seq: 1 }}, upsert: true)
        end

        doc['seq']
      end

    end
  end
end
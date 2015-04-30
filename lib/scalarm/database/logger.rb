# TODO tests
module Scalarm::Database
  class Logger
    @@loggers = []

    def self.register(logger)
      @@loggers << logger
    end

    def self.deregister_all
      @@loggers = []
    end

    def self.method_missing(name, *arguments, &block)
      @@loggers.each do |logger|
        logger.send(name, *arguments)
      end
    end
  end
end
# TODO tests
module Scalarm::Database
  class Logger
    @@loggers = []

    def self.register(logger)
      @loggers << logger
    end

    def self.method_missing(name)
      @loggers.each do |logger|
        logger.send(name)
      end
    end
  end
end
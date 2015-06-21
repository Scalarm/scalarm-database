require 'minitest/autorun'
require 'mocha/mini_test'

class LoggerTest < MiniTest::Test
  require 'scalarm/database/logger'

  def setup
    Scalarm::Database::Logger.deregister_all
  end

  def teardown
    Scalarm::Database::Logger.deregister_all
  end


  def test_empty_logger
    # TODO: change logger implementation as in Scalarm::ServiceCore
    skip 'logger tests are broken'

    Scalarm::Database::Logger.debug('b')
    Scalarm::Database::Logger.info('a')
    Scalarm::Database::Logger.warn('b')
    Scalarm::Database::Logger.error('b')
  end

  def test_delegation
    # TODO: change logger implementation as in Scalarm::ServiceCore
    skip 'logger tests are broken'

    rails_logger = mock 'rails logger'
    rails_logger.expects(:info).with('msg')

    other_logger = mock 'other logger'
    other_logger.expects(:info).with('msg')

    Scalarm::Database::Logger.register(rails_logger)
    Scalarm::Database::Logger.register(other_logger)

    Scalarm::Database::Logger.info('msg')
  end

  def test_deregister_all
    # TODO: change logger implementation as in Scalarm::ServiceCore
    skip 'logger tests are broken'

    one = mock 'two' do
      expects(:info).never
    end

    two = mock 'two' do
      expects(:info).never
    end

    Scalarm::Database::Logger::register(one)
    Scalarm::Database::Logger::register(two)

    Scalarm::Database::Logger.deregister_all

    Scalarm::Database::Logger.info
  end

end
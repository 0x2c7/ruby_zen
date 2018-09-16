require "bundler/setup"
require 'byebug'
require 'rspec'
require 'logger'
require 'ruby_zen'

class TestingLogger
  def initialize(output)
    @logger = Logger.new(output)
  end

  def debug(*args)
    @logger.debug(*args) if logger_enabled?
  end

  def info(*args)
    @logger.info(*args) if logger_enabled?
  end

  def warning(*args)
    @logger.warning(*args) if logger_enabled?
  end

  def error(*args)
    @logger.error(*args) if logger_enabled?
  end

  def fatal(*args)
    @logger.fatal(*args) if logger_enabled?
  end

  private

  def logger_enabled?
    !ENV['LOGGER_ENABLED'].nil?
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

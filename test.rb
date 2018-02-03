require 'yarv_generator'
require 'pp'
require 'ruby_zen'
require 'logger'

code = File.read('./spec/definitions/class_method_1.rb')
iseq = YarvGenerator.build_from_source(code)

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
engine = RubyZen::Engine.new(logger: logger)
engine.index_iseq(iseq)
puts "========== Instance Methods =========="
pp engine.fetch_class('Contract').instance_method_objects(false)
puts "========== Class Methods =========="
pp engine.fetch_class('Contract').class_method_objects(false)

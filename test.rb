require 'yarv_generator'
require 'pp'
require 'ruby_zen'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
engine = RubyZen::Engine.new(logger: logger)

def test_index(file, klass, engine)
  code = File.read(file)
  iseq = YarvGenerator.build_from_source(code)
  puts "========== Sample Code =========="
  puts code
  puts "========== Indexing code =========="
  engine.index_iseq(iseq)
  puts "========== Instance Methods =========="
  pp engine.fetch_class(klass).instance_method_objects(false)
  puts "========== Class Methods =========="
  pp engine.fetch_class(klass).class_method_objects(false)
end

test_index('./spec/definitions/method_1.rb', 'Order', engine)
test_index('./spec/definitions/class_method_1.rb', 'Contract', engine)


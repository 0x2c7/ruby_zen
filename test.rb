require 'yarv_generator'
require 'pp'
require 'ruby_zen'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
engine = RubyZen::Engine.new(logger: logger)

def test_index(file, engine, *classes)
  code = File.read(file)
  iseq = YarvGenerator.build_from_source(code)
  puts "========== Sample Code =========="
  puts code
  puts "========== YARV =========="
  puts iseq.inspect
  puts "========== Indexing code =========="
  engine.index_iseq(iseq)
  classes.each do |klass|
    puts "========== #{klass} =========="
    puts "== Instance Methods =="
    pp engine.fetch_class(klass).instance_method_objects
    puts "== Class Methods =="
    pp engine.fetch_class(klass).class_method_objects
  end
end

# test_index('./spec/definitions/method_1.rb', engine, 'Order')
# test_index('./spec/definitions/class_method_1.rb', engine, 'Contract')
test_index('./spec/definitions/method_2.rb', engine, 'Hello::World', 'Hello::World::Greet', 'Hello::World::Meeting')
puts "hihi"

require 'yarv_generator'
require 'pp'
require 'ruby_zen'
require 'logger'

code = File.read('./spec/definitions/method_1.rb')
iseq = YarvGenerator.build_from_source(code)
puts iseq.inspect

logger = Logger.new(STDOUT)
engine = RubyZen::Engine.new(logger: logger)
engine.index_iseq(iseq)
pp engine.fetch_class('Order').instance_method_objects(false)

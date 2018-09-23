require 'spec_helper'

RSpec.describe 'index instance methods' do
  let(:class_name) { 'Order' }
  let(:code) do
    <<-RUBY
      class Order
        def calculate(a, b)
          puts a
          puts b
        end

        def finish(date, failed = false)
          puts date
          puts failed
        end

        def add(*items)
          puts items
        end

        def config(config_a: 1, config_b: 2, config_c:)
          puts config_a
          puts config_b
          puts config_c
        end

        def save(**metadata)
          puts metadata
        end

        def total(a, b, *c, d: 1, e:, &block)
          puts a
          puts b
          puts c
          puts d
          puts e
          block.call
        end

        define_method :upload do |a, b|
          puts a
          puts b
        end

        define_method :total_2, instance_method(:total)

        private

        def private_calculate(a, b)
          puts a, b
        end

        define_method :private_calculate_2 do |a, b|
          puts a, b
        end
      end
    RUBY
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }

  before do
    engine.index_iseq(code)
  end

  it 'supports normal method arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:calculate)
    expect(test_method.name).to eql(:calculate)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:req, :a], [:req, :b]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports optional arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:finish)
    expect(test_method.name).to eql(:finish)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:req, :date], [:opt, :failed, false]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports rest arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:add)
    expect(test_method.name).to eql(:add)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:rest, :items]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports keyword arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:config)
    expect(test_method.name).to eql(:config)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql(
      [
         [:keyreq, :config_c], [:key, :config_a, 1], [:key, :config_b, 2]
      ]
    )
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports rest keyword arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:save)
    expect(test_method.name).to eql(:save)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:keyrest, :metadata]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports mixing different types of arguments' do
    test_method = engine.fetch_class(class_name).instance_method(:total)
    expect(test_method.name).to eql(:total)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql(
      [
        [:req, :a], [:req, :b],
        [:rest, :c],
        [:keyreq, :e], [:key, :d, 1]
      ]
    )
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "define_method" syntax' do
    test_method = engine.fetch_class(class_name).instance_method(:upload)
    expect(test_method.name).to eql(:upload)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:req, :a], [:req, :b]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "define_method" using method object syntax' do
    test_method = engine.fetch_class(class_name).instance_method(:total_2)
    expect(test_method.name).to eql(:total_2)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql(
      [
        [:req, :a], [:req, :b],
        [:rest, :c],
        [:keyreq, :e], [:key, :d, 1]
      ]
    )
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports private method' do
    test_method = engine.fetch_class(class_name).instance_method(:private_calculate)
    expect(test_method.name).to eql(:private_calculate)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:req, :a], [:req, :b]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports private method using "define_method" syntax' do
    test_method = engine.fetch_class(class_name).instance_method(:private_calculate_2)
    expect(test_method.name).to eql(:private_calculate_2)
    expect(test_method.owner.fullname).to eql('Order')
    expect(test_method.parameters).to eql([[:req, :a], [:req, :b]])
    expect(test_method.super_method).to eql(nil)
  end
end

require 'spec_helper'

RSpec.describe 'index module' do
  let(:module_name) { 'SampleModule' }
  let(:code) do
    <<-CODE
      module SampleModule
        def greet(greeting)
          puts greeting
        end

        def self.clone(source)
          puts source
        end

        class << self
          def copy(source)
            puts source
          end

          define_method(:compare) do |other|
            puts other
          end
          define_method :copy_2, SampleModule.method(:copy)
          define_method :copy_3, SampleModule.method(:copy).to_proc
          define_method :copy_4, instance_method(:copy)
        end

        define_singleton_method(:destroy) do |force|
          puts a
        end
      end

      class << SampleModule
        def build(data)
          puts data
        end
      end

      def SampleModule.seal(key)
        puts key
      end
    CODE
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  it 'indexes module correctly' do
    test_module = engine.fetch_class(module_name)
    expect(test_module.is_module).to be true
  end

  it 'supports normal definition' do
    test_method = engine.fetch_class(module_name).instance_method_object(:greet)
    expect(test_method.name).to eql(:greet)
    expect(test_method.owner.fullname).to eql('SampleModule')
    expect(test_method.parameters).to eql([[:req, :greeting]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "self.method" syntax' do
    test_method = engine.fetch_class(module_name).class_method_object(:clone)
    expect(test_method.name).to eql(:clone)
    expect(test_method.owner.fullname).to eql('SampleModule')
    expect(test_method.parameters).to eql([[:req, :source]])
    expect(test_method.super_method).to eql(nil)
  end

  context 'supports "class << self" syntax"' do
    it 'supports normal definition' do
      test_method = engine.fetch_class(module_name).class_method_object(:copy)
      expect(test_method.name).to eql(:copy)
      expect(test_method.owner.fullname).to eql('SampleModule')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method"' do
      test_method = engine.fetch_class(module_name).class_method_object(:compare)
      expect(test_method.name).to eql(:compare)
      expect(test_method.owner.fullname).to eql('SampleModule')
      expect(test_method.parameters).to eql([[:req, :other]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from method instance' do
      test_method = engine.fetch_class(module_name).class_method_object(:copy_2)
      expect(test_method.name).to eql(:copy_2)
      expect(test_method.owner.fullname).to eql('SampleModule')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from a method proc' do
      test_method = engine.fetch_class(module_name).class_method_object(:copy_3)
      expect(test_method.name).to eql(:copy_3)
      expect(test_method.owner.fullname).to eql('SampleModule')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from an internal method instance' do
      test_method = engine.fetch_class(module_name).class_method_object(:copy_4)
      expect(test_method.name).to eql(:copy_4)
      expect(test_method.owner.fullname).to eql('SampleModule')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end
  end

  it 'supports "define_singleton_method" syntax' do
    test_method = engine.fetch_class(module_name).class_method_object(:destroy)
    expect(test_method.name).to eql(:destroy)
    expect(test_method.owner.fullname).to eql('SampleModule')
    expect(test_method.parameters).to eql([[:req, :force]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "class << SampleModule" syntax' do
    test_method = engine.fetch_class(module_name).class_method_object(:build)
    expect(test_method.name).to eql(:build)
    expect(test_method.owner.fullname).to eql('SampleModule')
    expect(test_method.parameters).to eql([[:req, :data]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "def SampleModule.method" syntax' do
    test_method = engine.fetch_class(module_name).class_method_object(:seal)
    expect(test_method.name).to eql(:seal)
    expect(test_method.owner.fullname).to eql('SampleModule')
    expect(test_method.parameters).to eql([[:req, :key]])
    expect(test_method.super_method).to eql(nil)
  end
end

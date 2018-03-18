require 'spec_helper'

RSpec.describe 'index class method' do
  let(:class_name) { 'ClassMethodDummy' }
  let(:code) do
    <<-CODE
      class ClassMethodDummy
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
          define_method :copy_2, ClassMethodDummy.method(:copy)
          define_method :copy_3, ClassMethodDummy.method(:copy).to_proc
          define_method :copy_4, instance_method(:copy)
        end

        define_singleton_method(:destroy) do |force|
          puts a
        end
      end

      class << ClassMethodDummy
        def build(data)
          puts data
        end
      end

      def ClassMethodDummy.seal(key)
        puts key
      end
    CODE
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  it 'supports "self.method" syntax' do
    test_method = engine.fetch_class(class_name).class_method_object(:clone)
    expect(test_method.name).to eql(:clone)
    expect(test_method.owner.fullname).to eql('ClassMethodDummy')
    expect(test_method.parameters).to eql([[:req, :source]])
    expect(test_method.super_method).to eql(nil)
  end

  context 'supports "class << self" syntax"' do
    it 'supports normal definition' do
      test_method = engine.fetch_class(class_name).class_method_object(:copy)
      expect(test_method.name).to eql(:copy)
      expect(test_method.owner.fullname).to eql('ClassMethodDummy')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method"' do
      test_method = engine.fetch_class(class_name).class_method_object(:compare)
      expect(test_method.name).to eql(:compare)
      expect(test_method.owner.fullname).to eql('ClassMethodDummy')
      expect(test_method.parameters).to eql([[:req, :other]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from method instance' do
      test_method = engine.fetch_class(class_name).class_method_object(:copy_2)
      expect(test_method.name).to eql(:copy_2)
      expect(test_method.owner.fullname).to eql('ClassMethodDummy')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from a method proc' do
      test_method = engine.fetch_class(class_name).class_method_object(:copy_3)
      expect(test_method.name).to eql(:copy_3)
      expect(test_method.owner.fullname).to eql('ClassMethodDummy')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end

    it 'supports "define_method" from an internal method instance' do
      test_method = engine.fetch_class(class_name).class_method_object(:copy_4)
      expect(test_method.name).to eql(:copy_4)
      expect(test_method.owner.fullname).to eql('ClassMethodDummy')
      expect(test_method.parameters).to eql([[:req, :source]])
      expect(test_method.super_method).to eql(nil)
    end
  end

  it 'supports "define_singleton_method" syntax' do
    test_method = engine.fetch_class(class_name).class_method_object(:destroy)
    expect(test_method.name).to eql(:destroy)
    expect(test_method.owner.fullname).to eql('ClassMethodDummy')
    expect(test_method.parameters).to eql([[:req, :force]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "class << ClassMethodDummy" syntax' do
    test_method = engine.fetch_class(class_name).class_method_object(:build)
    expect(test_method.name).to eql(:build)
    expect(test_method.owner.fullname).to eql('ClassMethodDummy')
    expect(test_method.parameters).to eql([[:req, :data]])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports "def ClassMethodDummy.method" syntax' do
    test_method = engine.fetch_class(class_name).class_method_object(:seal)
    expect(test_method.name).to eql(:seal)
    expect(test_method.owner.fullname).to eql('ClassMethodDummy')
    expect(test_method.parameters).to eql([[:req, :key]])
    expect(test_method.super_method).to eql(nil)
  end
end

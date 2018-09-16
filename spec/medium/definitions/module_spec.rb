require 'spec_helper'

RSpec.describe 'index module' do
  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }

  before do
    engine.index_iseq(code)
  end

  context 'class methods' do
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

  context 'modules within modules' do
    let(:module_1) { 'FirstModule' }
    let(:module_2) { 'SecondModule' }
    let(:module_3) { 'ThirdModule' }
    let(:module_4) { 'FourthModule' }

    let(:indexed_module_one) { engine.fetch_class(module_1) }
    let(:indexed_module_two) { engine.fetch_class(module_2) }
    let(:indexed_module_three) { engine.fetch_class(module_3) }
    let(:indexed_module_four) { engine.fetch_class(module_4) }

    let(:code) do
      <<-CODE
        module FirstModule
          include FourthModule
          include SecondModule
          extend ThirdModule

          def soar
            "soaring..."
          end

          def fly
            "flying..."
          end

          def float
            "floating..."
          end
        end

        module SecondModule
          extend FourthModule
          prepend FourthModule

          def SecondModule.sing; end

          def sing
            "sing..."
          end

          def soar
            "soaring..."
          end

          def fly
            "flying..."
          end
        end

        module ThirdModule
          include SecondModule
          prepend FirstModule
          extend FirstModule
          extend SecondModule

          def swim
            "swimming..."
          end

          def play
            "playing..."
          end

          def fly
            "flying..."
          end
        end

        module FourthModule
          def self.sing; end
          def FourthModule.run; end

          def sing
            "singing..."
          end

          def run
            "running..."
          end
        end
      CODE
    end

    context 'FirstModule' do
      it 'is indexed correctly' do
        expect(indexed_module_one.is_module).to be true
      end

      it 'has included modules' do
        included_modules = indexed_module_one.included_modules

        expect(included_modules.length).to eq(2)
        expect(included_modules[module_4]).to eq(indexed_module_four)
        expect(included_modules[module_2]).to eq(indexed_module_two)
      end

      it 'returns correct accessible instance methods' do
        instance_methods = indexed_module_one.instance_method_objects

        expect(instance_methods.length).to eq(5)
        expect(instance_methods[:sing].owner).to eq(indexed_module_four)
        expect(instance_methods[:run].owner).to eq(indexed_module_four)
        expect(instance_methods[:soar].owner).to eq(indexed_module_one)
        expect(instance_methods[:fly].owner).to eq(indexed_module_one)
        expect(instance_methods[:float].owner).to eq(indexed_module_one)
      end

      it 'returns correct accessible class methods' do
        class_methods = indexed_module_one.class_method_objects(true)

        expect(class_methods.length).to eq(7)
        expect(class_methods[:sing].owner).to eq(indexed_module_four)
        expect(class_methods[:run].owner).to eq(indexed_module_four)
        expect(class_methods[:soar].owner).to eq(indexed_module_one)
        expect(class_methods[:fly].owner).to eq(indexed_module_one)
        expect(class_methods[:swim].owner).to eq(indexed_module_three)
        expect(class_methods[:play].owner).to eq(indexed_module_three)
        expect(class_methods[:float].owner).to eq(indexed_module_one)
      end
    end

    context 'SecondModule' do
      it 'is indexed correctly' do
        expect(indexed_module_two.is_module).to be true
      end

      it 'has extended and prepended modules' do
        extended_modules = indexed_module_two.extended_modules
        prepended_modules = indexed_module_two.prepended_modules

        expect(extended_modules.length).to eq(1)
        expect(extended_modules[module_4]).to eq(indexed_module_four)

        expect(prepended_modules.length).to eq(1)
        expect(prepended_modules[module_4]).to eq(indexed_module_four)
      end

      it 'returns correct accessible instance methods' do
        instance_methods = indexed_module_two.instance_method_objects

        expect(instance_methods.length).to eq(4)
        expect(instance_methods[:sing].owner).to eq(indexed_module_four)
        expect(instance_methods[:run].owner).to eq(indexed_module_four)
        expect(instance_methods[:soar].owner).to eq(indexed_module_two)
        expect(instance_methods[:fly].owner).to eq(indexed_module_two)
      end

      it 'returns correct accessible class methods' do
        class_methods = indexed_module_two.class_method_objects(true)

        expect(class_methods.length).to eq(2)
        expect(class_methods[:sing].owner).to eq(indexed_module_two.singleton_class)
        expect(class_methods[:run].owner).to eq(indexed_module_four)
      end
    end

    context 'ThirdModule' do
      it 'is indexed correctly' do
        expect(indexed_module_three.is_module).to be true
      end

      it 'has included, extended and prepended modules' do
        included_modules = indexed_module_three.included_modules
        extended_modules = indexed_module_three.extended_modules
        prepended_modules = indexed_module_three.prepended_modules

        expect(included_modules.length).to eq(1)
        expect(included_modules[module_2]).to eq(indexed_module_two)

        expect(extended_modules.length).to eq(2)
        expect(extended_modules[module_1]).to eq(indexed_module_one)
        expect(extended_modules[module_2]).to eq(indexed_module_two)

        expect(prepended_modules.length).to eq(1)
        expect(prepended_modules[module_1]).to eq(indexed_module_one)
      end

      it 'returns correct accessible instance methods' do
        instance_methods = indexed_module_three.instance_method_objects

        expect(instance_methods.length).to eq(7)
        expect(instance_methods[:sing].owner).to eq(indexed_module_four)
        expect(instance_methods[:run].owner).to eq(indexed_module_four)
        expect(instance_methods[:soar].owner).to eq(indexed_module_one)
        expect(instance_methods[:fly].owner).to eq(indexed_module_one)
        expect(instance_methods[:swim].owner).to eq(indexed_module_three)
        expect(instance_methods[:play].owner).to eq(indexed_module_three)
        expect(instance_methods[:float].owner).to eq(indexed_module_one)
      end

      it 'returns correct accessible class methods' do
        class_methods = indexed_module_three.class_method_objects(true)

        expect(class_methods.length).to eq(5)
        expect(class_methods[:float].owner).to eq(indexed_module_one)
        expect(class_methods[:sing].owner).to eq(indexed_module_four)
        expect(class_methods[:run].owner).to eq(indexed_module_four)
        expect(class_methods[:soar].owner).to eq(indexed_module_two)
        expect(class_methods[:fly].owner).to eq(indexed_module_two)
      end
    end

    context 'FourthModule' do
      it 'is indexed correctly' do
        expect(indexed_module_four.is_module).to be true
      end

      it 'returns correct accessible instance methods' do
        instance_methods = indexed_module_four.instance_method_objects

        expect(instance_methods.length).to eq(2)
        expect(instance_methods[:sing].owner).to eq(indexed_module_four)
        expect(instance_methods[:run].owner).to eq(indexed_module_four)
      end

      it 'returns correct accessible class methods' do
        class_methods = indexed_module_four.class_method_objects(true)

        expect(class_methods.length).to eq(2)
        expect(class_methods[:sing].owner).to eq(indexed_module_four.singleton_class)
        expect(class_methods[:run].owner).to eq(indexed_module_four.singleton_class)
      end
    end
  end
end

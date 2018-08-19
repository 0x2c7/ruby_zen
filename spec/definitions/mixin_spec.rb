require 'spec_helper'

RSpec.describe 'index mixin-ed class' do
  let(:class_name) { 'SampleClass' }
  let(:module_1) { 'FirstModule' }
  let(:module_2) { 'SecondModule' }

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  context 'include' do
    let(:code) do
      <<-CODE
        class SampleClass
          include FirstModule
          include SecondModule

          def self.class_method; end

          def breathe
           "breathing..."
          end

          def fly
            "flying..."
          end
        end

        module FirstModule
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
          def SecondModule.module_class_method; end

          def soar
            "soaring..."
          end
        end
      CODE
    end

    it 'indexes included module' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      included_modules = engine.fetch_class(class_name).included_modules

      expect(included_modules.length).to eq(2)
      expect(included_modules[module_1]).to eql(indexed_module_one)
      expect(included_modules[module_2]).to eql(indexed_module_two)
    end

    it 'returns correct accessible methods' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      indexed_class = engine.fetch_class(class_name)
      instance_methods = indexed_class.instance_method_objects

      expect(instance_methods.length).to eq(4)
      expect(instance_methods[:breathe].owner).to eq(indexed_class)
      expect(instance_methods[:fly].owner).to eq(indexed_class)
      expect(instance_methods[:soar].owner).to eq(indexed_module_two)
      expect(instance_methods[:float].owner).to eq(indexed_module_one)
    end
  end

  context 'extend' do
    let(:code) do
      <<-CODE
        class SampleClass
          extend FirstModule
          extend SecondModule

          def self.breathe
           "breathing..."
          end

          def SampleClass.fly
            "flying..."
          end

          def an_instance_method; end
        end

        module FirstModule
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
          def SecondModule.module_class_method; end

          def soar
            "soaring..."
          end
        end
      CODE
    end

    it 'indexes extended modules' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      extended_modules = engine.fetch_class(class_name).extended_modules

      expect(extended_modules.length).to eq(2)
      expect(extended_modules[module_1]).to eql(indexed_module_one)
      expect(extended_modules[module_2]).to eql(indexed_module_two)
    end

    it 'returns correct accessible class methods' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      indexed_class = engine.fetch_class(class_name)
      class_methods = indexed_class.class_method_objects

      expect(class_methods.length).to eq(4)
      expect(class_methods[:breathe].owner).to eq(indexed_class.singleton_class)
      expect(class_methods[:fly].owner).to eq(indexed_class.singleton_class)
      expect(class_methods[:soar].owner).to eq(indexed_module_two)
      expect(class_methods[:float].owner).to eq(indexed_module_one)
    end
  end

  context 'prepend' do
    let(:code) do
      <<-CODE
        class SampleClass
          prepend FirstModule
          prepend SecondModule

          def breathe
           "breathing..."
          end

          def fly
            "flying..."
          end

          def self.class_method; end
        end

        module FirstModule
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
          def SecondModule.module_class_method; end

          def soar
            "soaring..."
          end
        end
      CODE
    end

    it 'indexes prepended modules' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      prepended_modules = engine.fetch_class(class_name).prepended_modules

      expect(prepended_modules.length).to eq(2)
      expect(prepended_modules[module_1]).to eql(indexed_module_one)
      expect(prepended_modules[module_2]).to eql(indexed_module_two)
    end

    it 'returns correct accessible instance methods' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      indexed_class = engine.fetch_class(class_name)
      instance_methods = indexed_class.instance_method_objects

      expect(instance_methods.length).to eq(4)
      expect(instance_methods[:breathe].owner).to eq(indexed_class)
      expect(instance_methods[:fly].owner).to eq(indexed_module_one)
      expect(instance_methods[:soar].owner).to eq(indexed_module_two)
      expect(instance_methods[:float].owner).to eq(indexed_module_one)
    end
  end

  context 'mixin with include and prepend' do
    let(:code) do
      <<-CODE
        class SampleClass
          include FirstModule
          prepend SecondModule

          def breathe
           "breathing..."
          end

          def fly
            "flying..."
          end

          def self.class_method; end
        end

        module FirstModule
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
          def SecondModule.module_class_method; end

          def soar
            "soaring..."
          end

          def fly
            "flying..."
          end
        end
      CODE
    end

    it 'indexes included and prepended modules' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      included_modules = engine.fetch_class(class_name).included_modules
      prepended_modules = engine.fetch_class(class_name).prepended_modules

      expect(included_modules.length).to eq(1)
      expect(prepended_modules.length).to eq(1)
      expect(included_modules[module_1]).to eql(indexed_module_one)
      expect(prepended_modules[module_2]).to eql(indexed_module_two)
    end

    it 'returns correct accessible instance methods' do
      indexed_module_one = engine.fetch_class(module_1)
      indexed_module_two = engine.fetch_class(module_2)
      indexed_class = engine.fetch_class(class_name)
      instance_methods = indexed_class.instance_method_objects

      expect(instance_methods.length).to eq(4)
      expect(instance_methods[:breathe].owner).to eq(indexed_class)
      expect(instance_methods[:fly].owner).to eq(indexed_module_two)
      expect(instance_methods[:soar].owner).to eq(indexed_module_two)
      expect(instance_methods[:float].owner).to eq(indexed_module_one)
    end
  end

  context 'complex mixin' do
    let(:parent_class) { 'ParentSampleClass'}
    let(:grandparent_class) { 'GrandparentSampleClass' }
    let(:module_3) { 'ThirdModule' }
    let(:indexed_module_one) { engine.fetch_class(module_1) }
    let(:indexed_module_two) { engine.fetch_class(module_2) }
    let(:indexed_module_three) { engine.fetch_class(module_3) }

    let(:code) do
      <<-CODE
        class SampleClass < ParentSampleClass
          include FirstModule
          prepend ThirdModule
          extend SecondModule

          def breathe
           "breathing..."
          end

          def fly
            "flying..."
          end

          def self.copy; end
        end

        module FirstModule
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
          def SecondModule.module_class_method; end

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

        class ParentSampleClass < GrandparentSampleClass
          include ThirdModule
          include SecondModule

          def self.stroll(source)
            puts source
          end

          class << self
            def copy(source)
              puts source
            end

            define_method(:compare) do |other|
              puts other
            end
            define_method :copy_2, ParentSampleClass.method(:copy)
            define_method :copy_3, ParentSampleClass.method(:copy).to_proc
            define_method :copy_4, instance_method(:copy)
          end

          define_singleton_method(:destroy) do |force|
            puts a
          end
        end

        class GrandparentSampleClass
          extend SecondModule

          def self.soar
            "soaring..."
          end

          def gardening
           "gardening.."
          end

          def GrandparentSampleClass.stroll
            "strolling..."
          end
        end

        class << GrandparentSampleClass
          def build(data)
            puts data
          end
        end

        def GrandparentSampleClass.seal(key)
          puts key
        end
      CODE
    end

    context 'ThirdModule' do
      it 'indexes prepended modules' do
        included_modules = engine.fetch_class(module_3).included_modules
        extended_modules = engine.fetch_class(module_3).extended_modules
        prepended_modules = engine.fetch_class(module_3).prepended_modules

        expect(included_modules.length).to eq(1)
        expect(included_modules[module_2]).to eql(indexed_module_two)

        expect(extended_modules.length).to eq(2)
        expect(extended_modules[module_1]).to eql(indexed_module_one)
        expect(extended_modules[module_2]).to eql(indexed_module_two)

        expect(prepended_modules.length).to eq(1)
        expect(prepended_modules[module_1]).to eql(indexed_module_one)
      end

      it 'returns correct accessible instance methods' do
        indexed_module = engine.fetch_class(module_3)
        instance_methods = indexed_module.instance_method_objects

        expect(instance_methods.length).to eq(5)
        expect(instance_methods[:soar].owner).to eq(indexed_module_one)
        expect(instance_methods[:fly].owner).to eq(indexed_module_one)
        expect(instance_methods[:swim].owner).to eq(indexed_module)
        expect(instance_methods[:play].owner).to eq(indexed_module)
        expect(instance_methods[:float].owner).to eq(indexed_module_one)
      end

      it 'returns correct accessible class method' do
        indexed_module = engine.fetch_class(module_3)
        class_methods = indexed_module.class_method_objects(true)

        expect(class_methods.length).to eq(3)
        expect(class_methods[:soar].owner).to eq(indexed_module_two)
        expect(class_methods[:fly].owner).to eq(indexed_module_two)
        expect(class_methods[:float].owner).to eq(indexed_module_one)
      end
    end

    context 'GrandparentSampleClass' do
      it 'indexes extended modules' do
        extended_modules = engine.fetch_class(grandparent_class).extended_modules

        expect(extended_modules.length).to eq(1)
        expect(extended_modules[module_2]).to eql(indexed_module_two)
      end

      it 'returns correct accessible instance method' do
        indexed_class = engine.fetch_class(grandparent_class)
        instance_methods = indexed_class.instance_method_objects

        expect(instance_methods.length).to eq(1)
        expect(instance_methods[:gardening].owner).to eq(indexed_class)
      end

      it 'returns correct accessible class method' do
        indexed_class = engine.fetch_class(grandparent_class)
        class_methods = indexed_class.class_method_objects

        expect(class_methods.length).to eq(5)
        expect(class_methods[:soar].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:fly].owner).to eq(indexed_module_two)
        expect(class_methods[:stroll].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:build].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:seal].owner).to eq(indexed_class.singleton_class)
      end
    end

    context 'ParentSampleClass' do
      it 'indexes included modules' do
        included_modules = engine.fetch_class(parent_class).included_modules

        expect(included_modules.length).to eq(2)
        expect(included_modules[module_2]).to eq(indexed_module_two)
        expect(included_modules[module_3]).to eq(indexed_module_three)
      end

      it 'returns correct accessible instance method' do
        indexed_class = engine.fetch_class(parent_class)
        indexed_parent_class = engine.fetch_class(grandparent_class)
        instance_methods = indexed_class.instance_method_objects

        expect(instance_methods.length).to eq(6)
        expect(instance_methods[:soar].owner).to eq(indexed_module_two)
        expect(instance_methods[:fly].owner).to eq(indexed_module_two)
        expect(instance_methods[:swim].owner).to eq(indexed_module_three)
        expect(instance_methods[:play].owner).to eq(indexed_module_three)
        expect(instance_methods[:float].owner).to eq(indexed_module_one)
        expect(instance_methods[:gardening].owner).to eq(indexed_parent_class)
      end

      it 'returns correct accessible class method' do
        indexed_class = engine.fetch_class(parent_class)
        indexed_parent_class = engine.fetch_class(grandparent_class)
        class_methods = indexed_class.class_method_objects

        expect(class_methods.length).to eq(11)
        expect(class_methods[:stroll].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:copy].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:copy_2].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:copy_3].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:copy_4].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:destroy].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:compare].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:build].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:seal].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:soar].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:fly].owner).to eq(indexed_module_two)
      end
    end

    context 'SampleClass' do
      it 'indexes included, extended and prepended modules' do
        included_modules = engine.fetch_class(class_name).included_modules
        extended_modules = engine.fetch_class(class_name).extended_modules
        prepended_modules = engine.fetch_class(class_name).prepended_modules

        expect(included_modules.length).to eq(1)
        expect(extended_modules.length).to eq(1)
        expect(prepended_modules.length).to eq(1)
        expect(included_modules[module_1]).to eql(indexed_module_one)
        expect(extended_modules[module_2]).to eql(indexed_module_two)
        expect(prepended_modules[module_3]).to eql(indexed_module_three)
      end

      it 'returns correct accessible instance method' do
        indexed_class = engine.fetch_class(class_name)
        indexed_grandparent_class = engine.fetch_class(grandparent_class)
        instance_methods = indexed_class.instance_method_objects

        expect(instance_methods.length).to eq(7)
        expect(instance_methods[:breathe].owner).to eq(indexed_class)
        expect(instance_methods[:soar].owner).to eq(indexed_module_one)
        expect(instance_methods[:fly].owner).to eq(indexed_module_one)
        expect(instance_methods[:swim].owner).to eq(indexed_module_three)
        expect(instance_methods[:play].owner).to eq(indexed_module_three)
        expect(instance_methods[:float].owner).to eq(indexed_module_one)
        expect(instance_methods[:gardening].owner).to eq(indexed_grandparent_class)
      end

      it 'returns correct accessible class method' do
        indexed_class = engine.fetch_class(class_name)
        indexed_parent_class = engine.fetch_class(parent_class)
        indexed_grandparent_class = engine.fetch_class(grandparent_class)
        class_methods = indexed_class.class_method_objects

        expect(class_methods.length).to eq(11)
        expect(class_methods[:soar].owner).to eq(indexed_module_two)
        expect(class_methods[:fly].owner).to eq(indexed_module_two)
        expect(class_methods[:build].owner).to eq(indexed_grandparent_class.singleton_class)
        expect(class_methods[:seal].owner).to eq(indexed_grandparent_class.singleton_class)
        expect(class_methods[:stroll].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:copy].owner).to eq(indexed_class.singleton_class)
        expect(class_methods[:copy_2].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:copy_3].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:copy_4].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:destroy].owner).to eq(indexed_parent_class.singleton_class)
        expect(class_methods[:compare].owner).to eq(indexed_parent_class.singleton_class)
      end
    end
  end
end

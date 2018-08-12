require 'spec_helper'

RSpec.describe 'index class with the involvement of inheritance' do
  let(:parent_class_name) { 'ParentClass' }
  let(:child_class_name) { 'ChildClass' }
  let(:another_child_class_name) { 'AnotherChildClass' }
  let(:grandchild_class_name) { 'GrandChildClass' }

  let(:parent_class) { engine.fetch_class(parent_class_name) }
  let(:child_class) { engine.fetch_class(child_class_name) }
  let(:another_child_class) { engine.fetch_class(another_child_class_name) }
  let(:grandchild_class) { engine.fetch_class(grandchild_class_name) }

  let(:code) do
    <<-CODE
      class << GrandChildClass
        def build(data)
          puts data
        end

        def goodbye
          puts "bye felicia"
        end

        def greetings
          "ciao"
        end
      end

      class GrandChildClass < ChildClass
        def greetings
          puts "hello"
        end
      end

      class ChildClass < ParentClass
        def greetings
          puts "hello"
        end

        class << self
          def goodbye(args)
            puts args
          end

          def greetings
            "class greeting"
          end
        end

        def self.play
          "playing..."
        end

        def roll
          "rolling..."
        end
      end

      class ParentClass
        def greetings
          puts "hello"
        end

        def draw
          "drawing..."
        end

        def ParentClass.print
          "printing..."
        end

        def self.build
          "building..."
        end
      end

      def AnotherChildClass.seal(key)
        puts key
      end

      class AnotherChildClass < ParentClass
        def greetings
          puts "hello"
        end

        def self.greetings
          "hey..."
        end
      end
    CODE
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  context 'index' do
    it 'indexes classes as classes' do
      expect(child_class.is_module).to be false
      expect(parent_class.is_module).to be false
      expect(another_child_class.is_module).to be false
      expect(grandchild_class.is_module).to be false
    end

    it 'indexes inheritance hierachy correctly' do
      expect(child_class.superclass).to be(parent_class)
      expect(another_child_class.superclass).to be(parent_class)
      expect(grandchild_class.superclass).to be(child_class)
    end
  end

  context 'accessible methods' do
    context 'ParentClass' do
      it 'returns correct accessible instance methods' do
        instance_methods = parent_class.available_instance_methods

        expect(instance_methods.length).to eq(2)
        expect(instance_methods[:greetings].owner).to eq(parent_class)
        expect(instance_methods[:draw].owner).to eq(parent_class)
      end

      it 'returns correct accessible class methods' do
        class_methods = parent_class.available_class_methods

        expect(class_methods.length).to eq(2)
        expect(class_methods[:print].owner).to eq(parent_class.singleton_class)
        expect(class_methods[:build].owner).to eq(parent_class.singleton_class)
      end
    end

    context 'ChildClass' do
      it 'returns correct accessible instance methods' do
        instance_methods = child_class.available_instance_methods

        expect(instance_methods.length).to eq(3)
        expect(instance_methods[:greetings].owner).to eq(child_class)
        expect(instance_methods[:roll].owner).to eq(child_class)
        expect(instance_methods[:draw].owner).to eq(parent_class)
      end

      it 'returns correct accessible class methods' do
        class_methods = child_class.available_class_methods

        expect(class_methods.length).to eq(5)
        expect(class_methods[:print].owner).to eq(parent_class.singleton_class)
        expect(class_methods[:build].owner).to eq(parent_class.singleton_class)
        expect(class_methods[:play].owner).to eq(child_class.singleton_class)
        expect(class_methods[:goodbye].owner).to eq(child_class.singleton_class)
        expect(class_methods[:greetings].owner).to eq(child_class.singleton_class)
      end
    end

    context 'AnotherChildClass' do
      it 'returns correct accessible instance methods' do
        instance_methods = another_child_class.available_instance_methods

        expect(instance_methods.length).to eq(2)
        expect(instance_methods[:draw].owner).to eq(parent_class)
        expect(instance_methods[:greetings].owner).to eq(another_child_class)
      end

      it 'returns correct accessible class methods' do
        class_methods = another_child_class.available_class_methods

        expect(class_methods.length).to eq(4)
        expect(class_methods[:print].owner).to eq(parent_class.singleton_class)
        expect(class_methods[:build].owner).to eq(parent_class.singleton_class)
        expect(class_methods[:greetings].owner).to eq(another_child_class.singleton_class)
        expect(class_methods[:seal].owner).to eq(another_child_class.singleton_class)
      end
    end

    context 'GrandChildClass' do
      it 'returns correct accessible instance methods' do
        instance_methods = grandchild_class.available_instance_methods

        expect(instance_methods.length).to eq(3)
        expect(instance_methods[:greetings].owner).to eq(grandchild_class)
        expect(instance_methods[:draw].owner).to eq(parent_class)
        expect(instance_methods[:roll].owner).to eq(child_class)
      end

      it 'returns correct accessible class methods' do
        class_methods = grandchild_class.available_class_methods

        expect(class_methods.length).to eq(5)
        expect(class_methods[:build].owner).to eq(grandchild_class.singleton_class)
        expect(class_methods[:goodbye].owner).to eq(grandchild_class.singleton_class)
        expect(class_methods[:greetings].owner).to eq(grandchild_class.singleton_class)
        expect(class_methods[:play].owner).to eq(child_class.singleton_class)
        expect(class_methods[:print].owner).to eq(parent_class.singleton_class)
      end
    end
  end
end

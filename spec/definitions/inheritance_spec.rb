require 'spec_helper'

RSpec.describe 'index class with the involvement of inheritance' do
  let(:parent_class_name) { 'ParentClass' }
  let(:child_class_name) { 'ChildClass' }
  let(:another_child_class_name) { 'AnotherChildClass' }
  let(:grandchild_class_name) { 'GrandChildClass' }

  let(:code) do
    <<-CODE
      class ParentClass
        def greetings
          puts 'hello'
        end
      end

      class ChildClass < ParentClass
        def greetings
          puts 'hello'
        end
      end

      class AnotherChildClass < ParentClass
        def greeting
          puts 'hello'
        end
      end

      class GrandChildClass < ChildClass
        def greeting
          puts 'hello'
        end
      end
    CODE
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  it 'indexes inheritance hierachy correctly' do
    parent_class = engine.fetch_class(parent_class_name)
    child_class = engine.fetch_class(child_class_name)
    another_child_class = engine.fetch_class(another_child_class_name)
    grandchild_class = engine.fetch_class(grandchild_class_name)

    expect(child_class.superclass).to be(parent_class)
    expect(another_child_class.superclass).to be(parent_class)
    expect(grandchild_class.superclass).to be(child_class)
  end
end

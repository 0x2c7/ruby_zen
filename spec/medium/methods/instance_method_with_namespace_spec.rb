require 'spec_helper'

RSpec.describe 'index instance methods' do
  let(:code) do
    <<-RUBY
      module Hello
        class World
          def start
          end

          class Greet
            def say_hello
            end
          end
        end
      end

      class Hello::World::Greet
        def say_bye
        end
      end

      class Hello::World
        class Meeting
          def discuss
          end
        end
      end
    RUBY
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }

  before do
    engine.index_iseq(code)
  end

  it 'supports nested module syntax' do
    test_method = engine.fetch_class("Hello::World").instance_method(:start)
    expect(test_method.name).to eql(:start)
    expect(test_method.owner.fullname).to eql('Hello::World')
    expect(test_method.parameters).to eql([])
    expect(test_method.super_method).to eql(nil)

    test_method = engine.fetch_class("Hello::World::Greet").instance_method(:say_hello)
    expect(test_method.name).to eql(:say_hello)
    expect(test_method.owner.fullname).to eql('Hello::World::Greet')
    expect(test_method.parameters).to eql([])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports compact syntax' do
    test_method = engine.fetch_class("Hello::World::Greet").instance_method(:say_bye)
    expect(test_method.name).to eql(:say_bye)
    expect(test_method.owner.fullname).to eql('Hello::World::Greet')
    expect(test_method.parameters).to eql([])
    expect(test_method.super_method).to eql(nil)
  end

  it 'supports nested compact syntax' do
    test_method = engine.fetch_class("Hello::World::Meeting").instance_method(:discuss)
    expect(test_method.name).to eql(:discuss)
    expect(test_method.owner.fullname).to eql('Hello::World::Meeting')
    expect(test_method.parameters).to eql([])
    expect(test_method.super_method).to eql(nil)
  end
end

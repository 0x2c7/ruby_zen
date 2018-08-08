require 'spec_helper'

RSpec.describe 'index mixin-ed class' do
  let(:class_name) { 'Man' }
  let(:include_module) { 'UpOnTheSky' }
  let(:extend_module) { 'UnderTheSea' }
  let(:prepend_module) { 'OnTheGround' }
  let(:code) do
    <<-CODE
      class Man
        include UpOnTheSky
        extend UnderTheSea
        prepend OnTheGround
      end

      module UpOnTheSky
        def soar
          "soaring..."
        end
      end

      module UnderTheSea
        def dive
          "diving..."
        end
      end

      module OnTheGround
        def run
          "running..."
        end
      end
    CODE
  end

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }
  let(:iseq) { YarvGenerator.build_from_source(code) }

  before do
    engine.index_iseq(iseq)
  end

  it 'indexes included modules' do
    defined_module = engine.fetch_class(include_module)
    included_modules = engine.fetch_class(class_name).included_modules
    expect(included_modules[include_module]).to eql(defined_module)
  end

  it 'indexes extended modules' do
    defined_module = engine.fetch_class(extend_module)
    extended_modules = engine.fetch_class(class_name).extended_modules
    expect(extended_modules[extend_module]).to eql(defined_module)
  end

  it 'indexes prepended modules' do
    defined_module = engine.fetch_class(prepend_module)
    prepended_modules = engine.fetch_class(class_name).prepended_modules
    expect(prepended_modules[prepend_module]).to eql(defined_module)
  end
end

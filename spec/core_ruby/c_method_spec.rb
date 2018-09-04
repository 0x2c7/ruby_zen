require 'spec_helper'

RSpec.describe 'index c method' do
  let(:filename) { 'spec/core_ruby/array.c' }

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }

  before do
    engine.index_core_ruby(filename)
  end

  it 'indexes one file through' do
    array_class = engine.fetch_class('Array')
    expect(array_class.method_list.count).to eq(97)
  end
end

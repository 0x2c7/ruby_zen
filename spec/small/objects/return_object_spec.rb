require 'spec_helper'

RSpec.describe RubyZen::ReturnObject do
  let(:parent) { RubyZen::ClassObject.new('TestingClass') }
  subject { described_class.new(parent) }

  describe '#to_set' do
    context 'zero possibilities' do
      it 'returns empty set' do
        expect(subject.to_set).to be_empty
      end
    end

    context 'one-level possibilities' do
      let(:method_a) { RubyZen::MethodObject.new(:a) }
      let(:method_b) { RubyZen::MethodObject.new(:b) }

      before do
        subject.add(method_a)
        subject.add(method_b)
        subject.add(method_a)
      end

      it 'returns possibilities of that object' do
        expect(subject.to_set.to_a).to match_array(
          [method_a, method_b]
        )
      end
    end

    context 'nested possibilities' do
      let(:method_a) { RubyZen::MethodObject.new(:a) }
      let(:method_b) { RubyZen::MethodObject.new(:b) }
      let(:method_c) { RubyZen::MethodObject.new(:c) }
      let(:method_d) { RubyZen::MethodObject.new(:d) }

      before do
        subject.add(method_a)
        subject.add(method_b)
        subject.add(method_a)

        subject_2 = described_class.new(double)
        subject_2.add(method_a)
        subject_2.add(method_c)

        subject_3 = described_class.new(double)
        subject_3.add(method_b)
        subject_3.add(method_d)

        subject_2.add(subject_3)

        subject.add(subject_2)
        subject.add(described_class.new(double))
      end

      it 'returns merged possibilities from all nested' do
        expect(subject.to_set.to_a).to match_array(
          [method_a, method_b, method_c, method_d]
        )
      end
    end
  end
end

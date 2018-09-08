require 'spec_helper'

RSpec.describe RubyZen::ReturnObject do
  let(:parent) { RubyZen::MethodObject.new('method_a') }
  subject { described_class.new(parent) }

  describe '#to_set' do
    context 'zero possibilities' do
      it 'returns empty set' do
        expect(subject.to_set).to be_empty
      end
    end

    context 'one-level possibilities' do
      let(:class_a) { RubyZen::ClassObject.new(:a) }
      let(:class_b) { RubyZen::ClassObject.new(:b) }

      before do
        subject.add(class_a)
        subject.add(class_b)
        subject.add(class_a)
      end

      it 'returns possibilities of that object' do
        expect(subject.to_set.to_a).to match_array(
          [class_a, class_b]
        )
      end
    end

    context 'nested possibilities' do
      let(:class_a) { RubyZen::ClassObject.new(:a) }
      let(:class_b) { RubyZen::ClassObject.new(:b) }
      let(:class_c) { RubyZen::ClassObject.new(:c) }
      let(:class_d) { RubyZen::ClassObject.new(:d) }

      before do
        subject.add(class_a)
        subject.add(class_b)
        subject.add(class_a)

        subject_2 = described_class.new(double)
        subject_2.add(class_a)
        subject_2.add(class_c)

        subject_3 = described_class.new(double)
        subject_3.add(class_b)
        subject_3.add(class_d)

        subject_2.add(subject_3)

        subject.add(subject_2)
        subject.add(described_class.new(double))
      end

      it 'returns merged possibilities from all nested' do
        expect(subject.to_set.to_a).to match_array(
          [class_a, class_b, class_c, class_d]
        )
      end
    end
  end
end

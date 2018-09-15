require 'spec_helper'

RSpec.describe 'index internal ruby' do
  let(:filename) { 'spec/medium/methods/ruby' }
  let(:array) { engine.fetch_class('Array') }
  let(:object) { engine.fetch_class('Object') }
  let(:string) { engine.fetch_class('String') }
  let(:integer) { engine.fetch_class('Integer') }
  let(:float) { engine.fetch_class('Float') }
  let(:hash) { engine.fetch_class('Hash') }
  let(:numeric) { engine.fetch_class('Numeric') }
  let(:true_class) { engine.fetch_class('TrueClass') }
  let(:false_class) { engine.fetch_class('FalseClass') }
  let(:enumerable) { engine.fetch_class('Enumerable') }

  let(:engine) { RubyZen::Engine.new(logger: TestingLogger.new(STDOUT)) }

  before do
    engine.index_internal_ruby(filename)
  end

  context 'class' do
    it 'indexes correctly' do
      expect(engine.class_list.length).to eq(10)
      expect(array.superclass).to eq(object)
      expect(array.is_module).to be false
    end
  end

  context 'method' do
    context 'all methods' do
      it 'indexes correctly' do
        instance_methods = array.instance_method_objects
        class_methods = array.class_method_objects

        expect(instance_methods.count).to eq(10)
        expect(class_methods.count).to eq(4)
      end
    end

    context 'constructor' do
      it 'sets return object to owner of method' do
        method = array.class_method_object('new')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(1)
        expect(return_object.include?(array)).to be true
      end
    end

    context 'size' do
      it 'sets return object to Integer class' do
        method = array.instance_method_object('length')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(1)
        expect(return_object.include?(integer)).to be true
      end
    end

    context 'method ends with ?' do
      it 'sets possbile return objects to TrueClass and FalseClass' do
        method = array.instance_method_object('is_nil?')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(2)
        expect(return_object.include?(true_class)).to be true
        expect(return_object.include?(false_class)).to be true
      end
    end

    context 'aliased method' do
      it 'clones originial method and changes name' do
        original_method = array.instance_method_object('inspect')
        method = array.instance_method_object('to_s')
        return_object = method.return_object.to_set

        expect(method.owner).to be(original_method.owner)
        expect(return_object.length).to eq(1)
        expect(original_method.return_object.to_set.length).to eq(1)
        expect(return_object.include?(string)).to be true
        expect(original_method.return_object.to_set.include?(string)).to be true
      end
    end

    context 'call-seq is given in format ->' do
      it 'parses return objects correctly' do
        method = array.class_method_object('dup')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(3)
        expect(return_object.include?(hash)).to be true
        expect(return_object.include?(numeric)).to be true
        expect(return_object.include?(object)).to be true
      end
    end

    context 'call-seq is given in format =>' do
      it 'parses return objects correctly' do
        method = array.class_method_object('try_convert')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(5)
        expect(return_object.include?(hash)).to be true
        expect(return_object.include?(array)).to be true
        expect(return_object.include?(string)).to be true
        expect(return_object.include?(true_class)).to be true
        expect(return_object.include?(false_class)).to be true
      end
    end

    context 'call-seq is given in format =' do
      it 'parses return objects correctly' do
        method = array.instance_method_object('freeze')
        return_object = method.return_object.to_set

        expect(method.owner).to be(array)
        expect(return_object.length).to eq(3)
        expect(return_object.include?(hash)).to be true
        expect(return_object.include?(numeric)).to be true
        expect(return_object.include?(object)).to be true
      end
    end

    context 'call-seq is given but contains no actual information' do
      context 'method is of format to_' do
        it 'parses return objects correctly' do
          method = array.instance_method_object('to_a')
          return_object = method.return_object.to_set

          expect(method.owner).to be(array)
          expect(return_object.length).to eq(1)
          expect(return_object.include?(array)).to be true
        end
      end

      context 'normal method' do
        it 'sets return object to Object class' do
          method = array.class_method_object('abort')
          return_object = method.return_object.to_set

          expect(method.owner).to be(array)
          expect(return_object.length).to eq(1)
          expect(return_object.include?(object)).to be true
        end
      end
    end

    context 'call-seq is not given' do
      context 'method is of format to_' do
        it 'parses return objects correctly' do
          method = array.instance_method_object('to_f')
          return_object = method.return_object.to_set

          expect(method.owner).to be(array)
          expect(return_object.length).to eq(1)
          expect(return_object.include?(float)).to be true
        end
      end

      context 'normal method' do
        it 'sets return object to Object class' do
          method = array.instance_method_object('exit')
          return_object = method.return_object.to_set

          expect(method.owner).to be(array)
          expect(return_object.length).to eq(1)
          expect(return_object.include?(object)).to be true
        end
      end
    end
  end
end

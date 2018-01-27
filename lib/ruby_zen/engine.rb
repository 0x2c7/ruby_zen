module RubyZen
  class Engine
    attr_reader :classes

    INTERNAL_CLASSES = %w[
      Method Object BasicObject Encoding Comparable Enumerable String Exception Numeric
      Bignum Array Hash Struct Regexp Range IO Dir Time Random Proc Binding
      Math GC Enumerator Thread
    ].freeze

    def initialize(logger:)
      @classes = {}
      @logger = logger

      init_internal_classes
    end

    def analyze(iseq)
      raise "Type not support: #{iseq.class}" unless iseq.is_a?(YarvGenerator::Iseq)
    end

    private

    def init_internal_classes
      INTERNAL_CLASSES.each do |class_name|
        begin
          klass = Object.const_get(class_name)
          class_object = find_or_create_class_object(klass)

          klass.instance_methods.each do |method_name|
            method_object = create_method_object(klass.instance_method(method_name))
            class_object.define_method(method_object)
          end

          klass.methods.each do |method_name|
            method_object = create_method_object(klass.method(method_name))
            class_object.define_class_method(method_object)
          end

          @logger.debug("Finish indexing internal class #{class_name}")
        rescue NameError => e
          @logger.debug("Fail to index #{class_name}: #{e}")
        end
      end
    end

    def find_or_create_class_object(klass)
      return nil if klass.nil?

      class_name = klass.name
      return @classes[class_name] if @classes[class_name]

      superclass =
        if klass.respond_to?(:superclass)
          find_or_create_class_object(klass.superclass)
        end

      @classes[class_name] = RubyZen::ClassObject.new(
        class_name, superclass: superclass
      )
    end

    def create_method_object(native_method)
      return nil if native_method.nil?

      RubyZen::MethodObject.new(
        native_method.name,
        owner: find_or_create_class_object(native_method.owner),
        super_method: create_method_object(native_method.super_method)
      )
    end
  end
end

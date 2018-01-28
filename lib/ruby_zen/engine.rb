module RubyZen
  class Engine
    attr_reader :classes

    INTERNAL_CLASSES = %w[
      Kernel Method Object BasicObject Encoding Comparable Enumerable String
      Exception Numeric Bignum Array Hash Struct Regexp Range IO Dir Time Random
      Proc Binding Math GC Enumerator Thread
    ].freeze
    SINGLETON_CLASS_PATTERN = /^\#\<Class\:([^\>]+)\>$/

    def initialize(logger:)
      @classes = {}
      @logger = logger

      init_internal_classes
    end

    def index_iseq(iseq)
      raise "Type not support: #{iseq.class}" unless iseq.is_a?(YarvGenerator::Iseq)
    end

    def index_class(klass)
      class_object = find_or_create_class_object(klass)

      klass.instance_methods.each do |method_name|
        method_object = create_method_object(klass.instance_method(method_name))
        class_object.add_method(method_object)
      end

      klass.methods.each do |method_name|
        method_object = create_method_object(klass.method(method_name))
        class_object.add_class_method(method_object)
      end

      @logger.debug("Finish indexing #{klass}")
    end

    private

    def init_internal_classes
      INTERNAL_CLASSES.each do |class_name|
        begin
          klass = Object.const_get(class_name)
          index_class(klass)
        rescue NameError => e
          @logger.debug("Fail to index #{class_name}: #{e}")
        end
      end
    end

    def find_or_create_class_object(klass)
      return nil if klass.nil?

      if klass.name.nil?
        # Singleton class
        match = SINGLETON_CLASS_PATTERN.match(klass.to_s)
        return nil unless match
        original_klass = Object.const_get(match[1])
        @classes[original_klass.name] ||= RubyZen::ClassObject.new(
          original_klass.name,
          superclass: find_or_create_class_object(original_klass.superclass)
        )
        @classes[original_klass.name].singleton_class
      elsif !klass.respond_to?(:superclass)
        # Module
        @classes[klass.name] ||= RubyZen::ClassObject.new(
          klass.name,
          is_module: true
        )
      else
        # Normal class
        @classes[klass.name] ||= RubyZen::ClassObject.new(
          klass.name,
          superclass: find_or_create_class_object(klass.superclass)
        )
      end
    end

    def create_method_object(native_method)
      return nil if native_method.nil?

      RubyZen::MethodObject.new(
        native_method.name,
        owner: find_or_create_class_object(native_method.owner),
        super_method: create_method_object(native_method.super_method),
        parameters: native_method.parameters
      )
    end
  end
end

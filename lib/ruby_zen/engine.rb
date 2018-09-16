module RubyZen
  class Engine
    INTERNAL_CLASSES = %w[
      Kernel Method Object BasicObject Encoding Comparable Enumerable String
      Exception Numeric Bignum Array Hash Struct Regexp Range IO Dir Time Random
      Proc Binding Math GC Enumerator Thread
    ].freeze

    def initialize(
      logger:,
      include_internal_class: false
    )
      @classes = {}
      @logger = logger

      @logger.info('Starting RubyZen engine...')

      index_internal_classes if include_internal_class
      @logger.info('RubyZen is ready!')
    end

    def index_iseq(code)
      RubyZen::Indexers::IseqIndexer.new(
        code,
        engine: self,
        logger: @logger
      ).start
    end

    def index_class(klass)
      RubyZen::Indexers::ClassIndexer.new(
        klass,
        engine: self,
        logger: @logger
      ).start
    end

    def index_internal_ruby(filename)
      RubyZen::Indexers::RubyCoreIndexer.new(
        filename,
        engine: self,
        logger: @logger
      ).start
    end

    def class_list
      @classes
    end

    def fetch_class(class_name)
      @classes[class_name.to_s]
    end

    def define_class(class_name)
      class_name = class_name.to_s
      return @classes[class_name] unless block_given?

      class_object = yield
      if @classes[class_name]
        # Finalize class object type
        @classes[class_name].tap do |old_object|
          old_object.is_module = class_object.is_module
          old_object.namespace = class_object.namespace
          old_object.superclass = class_object.superclass
        end
      else
        @classes[class_name] = class_object
      end
    end

    def add_class_return_object(class_name, method_id, object)
      class_object = define_class(class_name)
      return if class_object.nil?
      class_object.add_method_return_object(method_id, object)
    end

    private

    def index_internal_classes
      INTERNAL_CLASSES.each do |class_name|
        begin
          klass = Object.const_get(class_name)
          RubyZen::Indexers::ClassIndexer.new(
            klass,
            engine: self,
            logger: @logger
          ).start
        rescue NameError => e
          @logger.debug("Fail to index #{class_name}: #{e}")
        end
      end
    end
  end
end

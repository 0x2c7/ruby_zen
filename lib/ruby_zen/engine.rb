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

    def index_iseq(iseq)
      RubyZen::Indexers::IseqIndexer.new(
        iseq,
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

    def fetch_class(class_name)
      @classes[class_name.to_s]
    end

    def define_class(class_name)
      class_name = class_name.to_s
      if @classes[class_name]
        @classes[class_name]
      elsif block_given?
        @classes[class_name] = yield
      else
        raise 'This method requires a block'
      end
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

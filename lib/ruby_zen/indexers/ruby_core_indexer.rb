module RubyZen::Indexers
  class RubyCoreIndexer
    require 'rdoc/rdoc'

    def initialize(filename, engine:, logger:)
      @filename = filename
      @engine = engine
      @logger = logger
    end

    def start
      rdoc = RDoc::RDoc.new
      rdoc.options = options
      rdoc.store = store

      parsed_internal_ruby = rdoc.parse_files([@filename])
      index_internal(parsed_internal_ruby[0])
    end

    def options
      @options ||= RDoc::Options.new
    end

    def store
      @store = RDoc::Store.new

      @store.encoding = options.encoding
      @store.dry_run  = options.dry_run
      @store.main     = options.main_page
      @store.title    = options.title
      @store.path     = options.op_dir

      @store
    end

    def index_internal(ruby)
      ruby.classes.each do |klass|
        class_object = define_class_object(klass)
        klass.method_list.each do |method|
          method_object = define_method_object(method, class_object)
          class_object.add_method(method_object)
        end
      end
    end

    def define_class_object(klass)
      @engine.define_class(klass.full_name) do
        RubyZen::ClassObject.new(klass.full_name)
      end
    end

    def define_method_object(method, klass)
      method_object = RubyZen::MethodObject.new(method.full_name, owner: klass)
      method_object.c_function = method.c_function
      method_object.call_seq = method.call_seq

      method_object
    end
  end
end

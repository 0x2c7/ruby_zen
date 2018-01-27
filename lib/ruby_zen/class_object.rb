module RubyZen
  class ClassObject
    attr_reader :name, :fullname, :is_singleton,
                :superclass, :singleton_class,
                :methods

    def initialize(fullname, is_singleton: false, superclass: nil)
      @fullname = fullname.to_s
      @name = @fullname.split('::').last

      @superclass = superclass
      @methods = {}

      unless is_singleton
        @singleton_class = RubyZen::ClassObject.new(
          fullname, is_singleton: true
        )
      end
    end

    def define_method(method_object)
      @methods[method_object.name] = method_object
    end

    def define_class_method(method_object)
      singleton_class.define_method(method_object)
    end
  end
end

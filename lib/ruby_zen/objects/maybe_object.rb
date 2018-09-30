require 'set'

module RubyZen
  class MaybeObject
    attr_reader :parent

    def initialize(possibilities = [])
      if possibilities.is_a?(Array)
        @possibilities = Set.new(possibilities)
      else
        @possibilities = Set.new
        @possibilities.add(possibilities)
      end
    end

    def add(object)
      @possibilities.add(object)
    end

    def replace(object)
      initialize(object)
    end

    def empty?
      @possibilities.empty?
    end

    def to_set
      possibilities = Set.new
      @possibilities.each do |possibility|
        if possibility.is_a?(self.class)
          possibilities += possibility.to_set
        else
          possibilities << possibility
        end
      end
      possibilities
    end

    def to_a
      to_set.to_a
    end

    def return_object_for(method_id)
      return_object = self.class.new
      to_a.each do |object|
        case object.class.name
        when ::RubyZen::MaybeObject.name
          return_object.add(object.return_object_for(method_id))
        when ::RubyZen::ClassObject.name
          return_object.add(object.class_method(method_id)&.return_object)
        when ::RubyZen::InstanceObject.name
          return_object.add(object.method(method_id)&.return_object)
        end
      end
      return_object
    end
  end
end

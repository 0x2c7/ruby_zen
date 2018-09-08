require 'set'

module RubyZen
  class ReturnObject
    attr_reader :parent

    def initialize(parent)
      @parent        = parent
      @possibilities = Set.new
    end

    def add(object)
      @possibilities.add(object)
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
  end
end

require 'set'

module RubyZen
  class MaybeClassObject
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
  end
end

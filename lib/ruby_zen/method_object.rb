module RubyZen
  class MethodObject
    attr_reader :name, :owner, :parameters, :super_method

    def initialize(name, owner: nil, parameters: [], super_method: nil)
      @name = name
      @owner = owner
      @parameters = parameters
      @super_method = super_method
    end
  end
end

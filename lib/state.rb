module SSM

  class State
    
    attr_reader :name
    
    def initialize(name, options = {})
      @name = name.to_sym
      self.freeze
    end
    
    def equal(state)
      self === state || @name === state.name
    end
  end
  
end
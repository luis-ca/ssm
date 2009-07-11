module SSM
    
  class StateTransition
    
    attr_reader :from, :to
    
    def initialize(from, to)
      @from, @to = from, to
    end
    
    def validate(current_state)
      return true if @to.nil?
      return true if @from.size == 0
      raise SSM::InvalidTransition unless @from.find {|state| state.equal(current_state)}
      true
    end
  
  end
  
end

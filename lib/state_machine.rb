require File.join(File.dirname(__FILE__), 'state')
require File.join(File.dirname(__FILE__), 'state_transition')
require File.join(File.dirname(__FILE__), 'event')

module SSM

  class StateMachine
    
    attr_reader :initial_state
    attr_accessor :current_state
    attr_accessor :property_name
    attr_accessor :use_property_index
    attr_reader :states
    attr_reader :events
    
    def initialize
      @states = []
      @events = []
    end
    
    def validate
      raise SSM::InitialStateRequired if @initial_state.nil?
      true
    end
    
    # Cloning is sufficent given that instances of SSM::State and SSM::Event are immutable. 
    # Furthermore, we freeze the Arrays storing those instances
    def clone_and_freeze
      clone = self.clone
      clone.init
      clone.freeze
      clone
    end
    
    def init
      @current_state = @initial_state
    end
    
    def freeze
      @states.freeze
      @events.freeze
      self
    end
    
    def initial_state=(state)
      self << state
      @initial_state = state
    end
    
    def << state_or_event
      
      if state_or_event.is_a?(SSM::State)
        push_state(state_or_event)
      elsif state_or_event.is_a?(SSM::Event)
        push_event(state_or_event)
      else
        raise TypeError
      end
    end
    
    def state_exists?(state_to_compare)
      @states.find { |existing_state| existing_state.equal(state_to_compare) }
    end
    
    def event_exists?(event_to_compare)
      @events.find { |existing_event| existing_event.equal(event_to_compare) }
    end
    
    def get_state_by_name(name)
      state = @states.find { |state| state.name == name}
      raise SSM::UndefinedState.new unless state.is_a?(SSM::State)
      state
    end
    
    def get_state_index_by_name(name)
      @states.index(get_state_by_name(name))
    end
    
    def get_state_by_index(index)
      @states[index.to_i]
    end
    
    def get_event_by_name(name)
      event = @events.find { |event| event.name == name}
      raise SSM::UndefinedEvent.new unless event.is_a?(SSM::Event)
      event
    end
    
    def transition(transition)
      begin
        transition.validate(@current_state)
        @current_state = transition.to
      rescue SSM::InvalidTransition => e
        raise e
      end
    end
    
    private
    
    def push_state(new_state)
      raise DuplicateState.new if state_exists?(new_state)
      @states << new_state
    end
    
    def push_event(new_event)
      raise DuplicateEvent.new if event_exists?(new_event)
      @events << new_event
    end
    
  end
  
  
  
  
  
end
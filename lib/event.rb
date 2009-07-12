module SSM

  class Event
    
    attr_reader :name
    attr_reader :block
    attr_reader :transition
    
    def initialize(name, transition=nil, &block) #:nodoc:
      @name, @transition  = name, transition
      @block = block if block
    end
    
    # Compares this Event with another Event and returns true if
    # either the Event is the same or the name of the Event is the same.
    def equal(event)
      self === event || @name === event.name
    end
    
  end
  
end
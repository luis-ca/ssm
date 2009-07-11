require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SSM::StateMachine do
  
  before :each do
    @sm = SSM::StateMachine.new
  end
  
  describe " - When new States are added, " do
    
    it "should succeed" do
      @sm << SSM::State.new(:first_state)
    end
    
    it "should fail if what we are trying to add is not a State" do
      lambda {
        @sm << Object.new
      }.should raise_error(TypeError)
    end
    
    it "should provide an Array with the States that were added" do
      @sm << SSM::State.new(:first_state)
      @sm << SSM::State.new(:second_state)
    
      @sm.states.should be_a(Array)
    end
    
    it "should allow retrieval of State by name" do
      @sm << state = SSM::State.new(:first_state)
      @sm << SSM::State.new(:second_state)
      @sm.get_state_by_name(:first_state).should equal(state)
    end
    
    it "should raise an SSM::UndefinedState exception when trying to retrieve an unexisting State by name" do
      lambda { @sm.get_state_by_name(:unexistent_state) }.should raise_error(SSM::UndefinedState)
    end
    
    it "should allow retrieval of State index" do
      @sm << state = SSM::State.new(:first_state)
      @sm << SSM::State.new(:second_state)
      @sm.get_state_index_by_name(:first_state).should equal(0)
      @sm.get_state_index_by_name(:second_state).should equal(1)
    end
    
    describe 'uniqueness' do
      
      it "should be enforced if the same State is added twice" do
        state = SSM::State.new(:first_state)
    
        lambda {
          @sm << state
          @sm << state
        }.should raise_error(SSM::DuplicateState)
    
        @sm.states.size.should eql(1)
      end
  
      it "should be enforced if two different States with the same name are added" do
        lambda {
          @sm << SSM::State.new(:first_state)
          @sm << SSM::State.new(:first_state)
        }.should raise_error(SSM::DuplicateState)
    
        @sm.states.size.should eql(1)
      end
      
    end
  end
  
  describe " - When an initial State is set, " do
    it "should succeed" do
      state = SSM::State.new(:first_state)
      @sm.initial_state = state
      @sm.initial_state.should eql(state)
      
      # Assigning initial_state will add the State to the StateMachine
      @sm.states.size.should eql(1)
    end
    
    it "should overide an existing initial state" do
      state_1 = SSM::State.new(:first_state)
      state_2 = SSM::State.new(:second_state)
      @sm.initial_state = state_1
      @sm.initial_state = state_2
      @sm.initial_state.should eql(state_2)
      
      # Assigning initial_state will add the State to the StateMachine
      @sm.states.size.should eql(2)
    end
    
    it "should fail if the State already exists" do
      
      # Given a StateMachine with one State
      state = SSM::State.new(:existing_state)
      @sm << state
      
      # And a StateMachine with a different initial_state
      initial_state = SSM::State.new(:initial_state)
      @sm.initial_state = initial_state
      
      # When I attempt to assign an existing State as the initial_state
      lambda {
        @sm.initial_state = state
      }.should raise_error(SSM::DuplicateState)
    end
  end
  
  describe " - When new Events are added, " do
    
    it "should succeed" do
      block = lambda { puts "code block" }
      
      @sm << SSM::Event.new(:an_event, {}, &block)
      @sm << SSM::Event.new(:another_event, {}, &block)
    end
    
    it "should allow retrival of Event by name" do
      block = lambda { puts "code block" }
      event = SSM::Event.new(:an_event, {}, &block) 
      @sm << event
      
      @sm.get_event_by_name(:an_event).should equal(event)
    end
    
    it "should raise an SSM::UndefinedEvent exception when trying to retrieve an unexisting Event by name" do
      lambda { @sm.get_event_by_name(:unexistent_event) }.should raise_error(SSM::UndefinedEvent)
    end
    
  end
  
end
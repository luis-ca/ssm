require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SSM::State do

  it "should create a new State and freeze it" do
    state = SSM::State.new(:first_state)
    state.should be_a(SSM::State)
    
    state.frozen?.should be_true
  end
  
  it "should return a symbol representing the state" do
    state = SSM::State.new("first_state")
    state.name.should equal(:first_state)
  end
  
  describe " - equal()" do
    
    it "should return true when comparing the same instance" do
      state = SSM::State.new(:a_state)
      state.equal(state).should eql(true)
    end
    
    it "should return true when comparing two different instances that have the same name" do
      state_1 = SSM::State.new(:a_state)
      state_2 = SSM::State.new(:a_state)
      
      state_1.equal(state_2).should eql(true)
    end
  end
  
end
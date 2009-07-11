require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SSM::StateTransition do
  
  it "should validate if no from States present" do
    current_state = SSM::State.new(:first_state)
    transition = SSM::StateTransition.new([], :first_state)
    transition.validate(current_state).should eql(true)
  end
  
  it "should return true if valid transition" do
    current_state = SSM::State.new(:first_state)
    next_state = SSM::State.new(:second_state)
    transition = SSM::StateTransition.new([current_state], next_state)
    transition.validate(current_state).should eql(true)
  end
  
  it "should throw InvalidTransition if invalid transition" do
    current_state = SSM::State.new(:first_state)
    next_state    = SSM::State.new(:second_state)
    other_state   = SSM::State.new(:other_state)
    transition    = SSM::StateTransition.new([other_state], next_state)
    
    lambda {
      transition.validate(current_state)
    }.should raise_error(SSM::InvalidTransition)
  end
end
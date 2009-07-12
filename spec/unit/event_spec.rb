require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SSM::Event do
  
  before :each do
    
  end
  
  it "should create a new Event" do
    block = lambda { puts "block of code" }
    
    event = SSM::Event.new(:an_event, nil, &block)
    event.should be_a(SSM::Event)
    event.name.should eql(:an_event)
  end
  
  it "should create a new Event with required params only" do
    event = SSM::Event.new(:an_event)
    event.should be_a(SSM::Event)
    event.name.should eql(:an_event)
  end
  
  describe " - equal()" do
    
    it "should return true when comparing the same instance" do
      event = SSM::Event.new(:an_event)
      event.equal(event).should eql(true)
    end
    
    it "should return true when comparing two different instances that have the same name" do
      event_1 = SSM::Event.new(:an_event)
      event_2 = SSM::Event.new(:an_event)
      
      event_1.equal(event_2).should eql(true)
    end
  end

end
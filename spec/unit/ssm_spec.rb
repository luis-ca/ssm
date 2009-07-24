require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SSM do
  
  context "when inherited" do
    it "should raise an Exception" do
      lambda {
        class InheritedClass < SSM::ClassMethod
        end
      }.should raise_error(Exception)
    end
  end
  
  context "when included" do
    
    before :each do
      class SimpleTestClass; include SSM; ssm_initial_state :initial_state; end
      class AnotherSimpleTestClass; include SSM; ssm_initial_state :initial_state; end
      
      class AMoreCompleteClass
        include SSM
        
        ssm_initial_state :one
        ssm_state :two
        
        ssm_event :to_two, :from => [], :to => :two do
        end
      end
    end
  
    after :each do
      Object.send(:remove_const, :SimpleTestClass)
      Object.send(:remove_const, :AnotherSimpleTestClass)
    end

    it 'should mixin SSM class methods' do
      SSM::ClassMethods.public_instance_methods.each do |method|
        SimpleTestClass.should respond_to(method.to_sym)
      end
    end
  
    it "should create a StateMachine template for that class" do
    end
  
    it "should not keep existing StateMachine template when class is redeclared" do
      original_template_state_machine_object_id = SimpleTestClass.template_state_machine.object_id
      Object.send(:remove_const, :SimpleTestClass)
      class SimpleTestClass; include SSM; end
    
      SimpleTestClass.template_state_machine.object_id.should_not eql(original_template_state_machine_object_id)
    end
  
    it "should behave normally if included twice" do
      # By definition it should work given http://www.ruby-doc.org/core/classes/Module.html#M001636
    end
  
    it "should share identical StateMachines between to instances of the same class" do
      # need to make sure they are identical, not the same
      # SimpleClass.new.ssm_state_machine.should eql(SimpleClass.new.ssm_state_machine)
    end

    it "should not share StateMachine between two instances of the same class" do
      SimpleTestClass.new.ssm_state_machine.object_id.should_not equal(SimpleTestClass.new.ssm_state_machine.object_id)
    end
  
    it "should not share StateMachines templates accross different classes" do
      SimpleTestClass.new.ssm_state_machine.object_id.should_not equal(AnotherSimpleTestClass.new.ssm_state_machine.object_id)
    end

    it "should allow for retrieval of all States using ssm_states" do
      states = AMoreCompleteClass.ssm_states
      
      states[0].should be_a(SSM::State)
      states[0].name.should eql(:one)
      
      states[1].should be_a(SSM::State)
      states[1].name.should eql(:two)
    end
    
    it "should allow for retrieval of all Events using ssm_events" do
      events = AMoreCompleteClass.ssm_events
      
      events[0].should be_a(SSM::Event)
      events[0].name.should eql(:to_two)
    end
  end

  context "when initialized" do
  
    before :each do
      class Foo
        include SSM

        ssm_inject_state_into :foo_property, :as_integer => true
      
        ssm_initial_state :foo_state_1
        ssm_state :foo_state_2
        ssm_state :foo_state_3
      
        ssm_event :foo_event_1, :from => [:foo_state_1], :to => :foo_state_2 do
        end
        ssm_event :foo_event_2, :from => [:foo_state_3],  :to => :foo_state_3 do
        end
        ssm_event :foo_event_3, :from => [],  :to => :foo_state_1 do |*args|
          args
        end
      end
      
      class Bar
        include SSM

        ssm_inject_state_into :bar_property
      
        ssm_initial_state :bar_state_1
        ssm_state :bar_state_2
        ssm_state :bar_state_3
      
        ssm_event :bar_event_1, :from => [:bar_state_1], :to => :bar_state_2 do
        end
        ssm_event :bar_event_2, :from => [:bar_state_3],  :to => :bar_state_3 do
        end
      end
    end
  
    after :each do
      Object.send(:remove_const, :Foo)
      Object.send(:remove_const, :Bar)
    end
  
    context " - States:" do
      
      it "should be set up" do
        Foo.new.ssm_state_machine.states.size.should eql(3)
      end
      
      it "should require an initial state" do
        lambda {
          class ClassWithoutInitialState
            include SSM
            ssm_state :foo_state
          end
          
          ClassWithoutInitialState.new
        }.should raise_error(SSM::InitialStateRequired)
        Object.send(:remove_const, :ClassWithoutInitialState)
      end
  
      it "should throw an exception if we try to set up a model with two or more States that are the same" do
        lambda {
          class ClassWithDuplicateStates
            include SSM
            ssm_state :foo_state
            ssm_state :foo_state
          end
        }.should raise_error(SSM::DuplicateState)
        Object.send(:remove_const, :ClassWithDuplicateStates)
      end
  
      it "should set an initial State" do
        class ClassForInitialState
          include SSM
          ssm_initial_state :foo_state
        end
    
        ClassForInitialState.ssm_initial_state.equal(SSM::State.new(:foo_state)).should be_true
        Object.send(:remove_const, :ClassForInitialState)
      end
    
      it "should customize State property" do
        Bar.new.bar_property.should equal(:bar_state_1)
      end
      
      it "should customize State property using index" do
        Foo.new.foo_property.should equal(0)
      end
      
    end

    context "- Events:" do
      
      it "should set up the Events" do
        model = Foo.new
        model.ssm_state_machine.events.size.should eql(3)
      end
      
      it "should throw an exception if we try to set up an event with no to state" do
        lambda {
          class ClassWithInvalidTransition
            include SSM
        
            ssm_event :no_to_state, {} do
            end
          end
        }.should raise_error(SSM::InvalidTransition)
        Object.send(:remove_const, :ClassWithInvalidTransition)
      end
      
      it "should throw an exception if we try to set up a model with two or more Events that are the same" do
        lambda {
          class ClassWithDuplicateEvents
            include SSM
            ssm_initial_state :foo_state
            ssm_event :foo_event, :to => :foo_state do; end;
            ssm_event :foo_event, :to => :foo_state do; end;
          end
        }.should raise_error(SSM::DuplicateEvent)
        Object.send(:remove_const, :ClassWithDuplicateEvents)
      end
      
      it "should accept arguments" do
        Foo.new.foo_event_3(1,2,3).should eql([1,2,3])
        Foo.new.foo_event_3(1).should eql([1])
        Foo.new.foo_event_3({:one => 1, :two => 2}).should ==([{:one => 1, :two => 2}])
      end
    end

    context "- Strategies:" do
      
    end
  end
  
  context "when instanciated" do
  
    before :each do
      class Foo
        include SSM

        ssm_inject_state_into :some_state_property
        
        ssm_initial_state :first_state
        ssm_state :second_state
        ssm_state :third_state

        def initialize(*args)
          @var = "initialization string"
        end

        ssm_event :first_to_second, :from => [:first_state], :to => :second_state do
          # code here
        end

        ssm_event :to_first, :from => [:second_state, :third_state], :to => :first_state do
          # code here
        end
      
        ssm_event :give_me_my_context, :to => :second_state do
          self
        end

      end
      
      class Baz
        include SSM

        ssm_inject_state_into :my_state, :as_integer => true
      
        ssm_initial_state :first_state
        ssm_state :second_state
        ssm_state :third_state
      
        ssm_event :my_event, :to => :second_state do
          puts "a code block"
        end

        ssm_event :my_other_event, :to => :second_state do
          puts "another code block"
        end
      end
    end
  
    after :each do
      Object.send(:remove_const, :Foo)
      Object.send(:remove_const, :Baz)
    end
  
    it "should clone the StateMachine template when initialized" do
      Foo.new.ssm_state_machine.should be_a(SSM::StateMachine)
    end
    
    it "should not allow to set ssm_state_machine" do
      model = Foo.new
      lambda {
        model.ssm_state_machine = Object.new
      }.should raise_error(NoMethodError)
    end
  
    it "should not allow an Event to describe a StateTransition with a State that does not exist" do
      lambda {
        class Bar
          include SSM
          ssm_event :first_to_second, :from => [:first_state], :to => :second_state do; end
        end
      }.should raise_error(SSM::UndefinedState)
      Object.send(:remove_const, :Bar)
    end
  
    it "should respond to an Event" do
      Foo.new.should respond_to(:first_to_second)
    end
  
    it "should execute the code block in the context of the main object" do
      model = Foo.new
      model.give_me_my_context.should equal(model)
    end
  
    it "should transition successfully" do
      model = Foo.new
      model.first_to_second
      model.ssm_state_machine.current_state.name.should eql(:second_state)
      lambda {
        model.first_to_second
      }.should raise_error(SSM::InvalidTransition)
    
      model.to_first
      model.ssm_state_machine.current_state.name.should eql(:first_state)
    end

    it "should attempt to update State property if it exists" do
      model = Foo.new
      model.some_state_property.should equal(:first_state)
      model.first_to_second
      model.some_state_property.should equal(:second_state)
    end

    it "should compare its State to another State (positive)" do
      model = Foo.new
      model.is?(:first_state).should be_true
      model.is?(:second_state).should be_false
      
      model.first_to_second
      model.is?(:first_state).should be_false
      model.is?(:second_state).should be_true
    end
    
    it "should compare its State to another State (negative)" do
      model = Foo.new
      model.is_not?(:first_state).should be_false
      model.is_not?(:second_state).should be_true
      
      model.first_to_second
      model.is_not?(:first_state).should be_true
      model.is_not?(:second_state).should be_false
    end

    it "should update State if ssm_inject_state_into is set and has a valid value" do
      model = Baz.new
      model.is?(:second_state).should be_false
      model.my_state = 1
      model.is_not?(:first_state).should be_true
    end
    
    it "should synchronize State when state is updated on model" do
      model = Baz.new
      model.my_state = 1
      model.send(:_synchronize_state).should be_true
      model.ssm_state_machine.current_state.name.should eql(:second_state)
    end
    
    it "should synchronize State when state is nil on model" do
      model = Baz.new
      model.my_state = nil
      model.my_state.should be_nil
      model.ssm_state_machine.current_state.name.should eql(:first_state)
      
      model.send(:_synchronize_state).should be_true
      model.my_state.should eql(0)
      model.ssm_state_machine.current_state.name.should eql(:first_state)
    end

    it "should return the State as a symbol" do
      Foo.new.ssm_state.should eql(:first_state)
    end
  end

  context "when allocated" do
    before :each do
      class Foo
        include SSM

        ssm_inject_state_into :some_state_property
        
        ssm_initial_state :first_state
        ssm_state :second_state
        ssm_state :third_state

        def initialize(*args)
          @var = "initialization string"
        end

        ssm_event :first_to_second, :from => [:first_state], :to => :second_state do
          # code here
        end

        ssm_event :to_first, :from => [:second_state, :third_state], :to => :first_state do
          # code here
        end
      
        ssm_event :give_me_my_context, :to => :second_state do
          self
        end

      end
    end
  
    after :each do
      Object.send(:remove_const, :Foo)
    end
    it "should clone the StateMachine template when initialized" do
      Foo.allocate.ssm_state_machine.should be_a(SSM::StateMachine)
    end
  end
end 
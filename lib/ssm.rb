require File.join(File.dirname(__FILE__), 'state_machine')
require File.join(File.dirname(__FILE__), 'injection_strategies', 'base')

# SSM - Simple State Machine mixin 
#
# SSM is a mixin that adds finite-state machine behavior to a class.
#
# Example usage:
#
#   class Door
#     include SSM
#
#     ssm_initial_state :closed
#     ssm_state :opened
#
#     ssm_event :open, :from => [:closed], :to => :opened do
#       puts "Just opened door"
#     end
#     
#     ssm_event :close, :from => [:opened], :to => :closed do
#       puts "Closed door"
#     end
#
#   end
# 
#   door = Door.new
#   door.open
#   door.is?(:opened) #=> true
#   door.close
#--
# Including SSM ensures that both class-level and instance-level methods are 
# available (through the use of extend on self.included). 
# 
# Each include on a class creates a new StateMachine template for the class it is being
# included in. The meta methods will then help build that template StateMachine.
#
# Each time an instance of the Foo class is created, the template StateMachine is cloned, 
# and attached to the new instance. The cloned StateMachine can not be manipulated at runtime.
# This ensures that as long as a class is not modified at runtime, all its instances' StateMachines
# are equivalent.
#--
module SSM
  
  VERSION = '0.1.7';

  class InvalidTransition     < RuntimeError; end
  class UndefinedState        < RuntimeError; end
  class DuplicateState        < RuntimeError; end
  class UndefinedEvent        < RuntimeError; end
  class DuplicateEvent        < RuntimeError; end
  class InitialStateRequired  < RuntimeError; end
  
  # TemplateStateMachines stores the StateMachine templates for each class
  # that includes SSM. Because all setup is done before instantiation, each
  # instance will then have a consistent StateMachine.
  TemplateStateMachines = {} #:nodoc:
  
  # First, extend the class with static methods as soon as the module is mixed in.
  # Then, initialize the StateMachine when the module is mixed in. This allows the meta 
  # calls to build the StateMachine before instantiation, and once the model is actually 
  # instanciated, store a copy of the StateMachine.
  #
  # Note: We use the actual Class as the key to the TemplateStateMachines hash. If the Class is redeclared, 
  # the hash will see it as a new key, even though if you inspect the hash you will see two keys whose string
  # representation is the same.
  def self.included(klass) #:nodoc:
    
    klass.extend SSM::ClassMethods
    SSM::TemplateStateMachines[klass] = SSM::StateMachine.new
    
    def klass.allocate(*args)
      instance = super(*args)
      setup(instance)
      instance
    end
    
    # Intercept contructor. We can't overide initialize given that the user 
    # may define their own initialize method.
    def klass.new(*args)
      instance = super(*args)
      setup(instance)
      instance
    end

    def klass.setup(instance)
      
      SSM::TemplateStateMachines[self].validate
      
      sm = SSM::TemplateStateMachines[self].clone_and_freeze
      instance.instance_variable_set(:@ssm_state_machine, sm)
      
      begin
        strategy_name = sm.injection_strategy.nil? ? "object" : sm.injection_strategy.to_s
        module_name = "#{strategy_name.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }}Strategy" # from ActiveSupport
        require File.join(File.dirname(__FILE__), 'injection_strategies', "#{strategy_name}_strategy.rb")
        instance.extend(SSM::InjectionStrategies.const_get(module_name))
      rescue
        raise
      end
      
      instance.ssm_setup
    end
        
  end
  
  
  # Class methods to be mixed in when the module is included.
  #
  #--
  # Note: self returns the actual class
  #--
  module ClassMethods

    attr_accessor :ssm_instance_property
    
    def inherited(subclass) #:nodoc:
      raise Exception.new("SSM cannot be inherited. Use include instead.")
    end 
    
    # This method is used as both a setter - in the context of the class declaration -
    # and a getter when called from an instance.
    #
    #   class Door
    #     include SSM
    #    
    #     ssm_initial_state :closed
    #   end
    #
    #   Door.new.ssm_initial_state #=> :closed
    #
    def ssm_initial_state(name=nil)
      name.nil? ? 
        SSM::TemplateStateMachines[self].initial_state :
        SSM::TemplateStateMachines[self].initial_state = SSM::State.new(name)
    end
    
    # Sets the instance attribute that stores a representation of the State. In
    # the first form, the property will return a symbol represeting the State.
    # In the second form, an index is returned, making it more convenient when
    # dealing with persistence.
    #
    #   class Door
    #     include SSM
    #
    #     ssm_inject_state_into :state
    #     ssm_initial_state :closed
    #   end
    #
    #   Door.new.state #=> :closed
    #
    #
    #   class Door
    #     include SSM
    #
    #     ssm_inject_state_into :state, :use_index
    #     ssm_initial_state :closed
    #   end
    #
    #   Door.new.state #=> 0
    #
    def ssm_inject_state_into(name, options={}, &block)
      SSM::TemplateStateMachines[self].property_name = name
      SSM::TemplateStateMachines[self].use_property_index = options[:as_integer].nil? ? false : true
      SSM::TemplateStateMachines[self].injection_strategy = options[:strategy] #SSM::InjectionStrategies::Base.factory(options[:strategy])
    end
    
    # Adds new States. This method takes a string or a symbol.
    #
    #   class Door
    #     include SSM
    #
    #     ssm_state :closed
    #     ssm_state :opened
    #   end
    #
    def ssm_state(name, options={})
      SSM::TemplateStateMachines[self] << SSM::State.new(name)
    end
    
    # Adds new Events. These Events can then be called as methods.
    #
    #   class Door
    #     include SSM
    #
    #     ssm_initial_state :closed
    #     ssm_state :opened
    #
    #     ssm_event :open, :from => [:closed], :to => :opened do
    #       puts "Just opened door"
    #     end
    #     
    #     ssm_event :close, :from => [:opened], :to => :closed do
    #       puts "Closed door"
    #     end
    #
    #   end
    # 
    #   door = Door.new
    #   door.open
    #   door.is?(:opened) #=> true
    #   door.closed
    #
    def ssm_event(name, options = {}, &block)
      
      msg = "Please specificy a final state for this transition. Use a lowly instance method if a transition is not required."
      raise SSM::InvalidTransition.new(msg) unless options[:to].is_a?(Symbol)
      
      begin
        # build Array of States this transition can be called from
        from = []
        if options[:from].is_a?(Array) and options[:from].size > 0
          options[:from].each { |state_name| from << SSM::TemplateStateMachines[self].get_state_by_name(state_name) }
        end
        
        to   = SSM::TemplateStateMachines[self].get_state_by_name(options[:to])
      rescue
        raise
      end
      
      # Create StateMachine and create method associated with this StateTransition
      SSM::TemplateStateMachines[self] << SSM::Event.new(name, SSM::StateTransition.new(from, to), &block)
      define_method("#{name.to_s}") { |*args| _synchronize_state; _ssm_trigger_event(name, args) }
    end
    
    def template_state_machine #:nodoc:
      SSM::TemplateStateMachines[self]
    end
    
    # Returns all the available Events
    def ssm_events
      template_state_machine.events
    end
    
    # Returns all the available States
    def ssm_states
      template_state_machine.states
    end
    
  end
  
  #
  # instance methods
  #
  attr_reader :ssm_state_machine
  
  # Returns true if the Object is in the State represented by the name or symbol.
  #
  #   class Door
  #     include SSM
  #
  #     ssm_initial_state :closed
  #     ssm_state :opened
  #
  #     ssm_event :open, :from => [:closed], :to => :opened do
  #       puts "Just opened door"
  #     end
  #     
  #     ssm_event :close, :from => [:opened], :to => :closed do
  #       puts "Closed door"
  #     end
  #
  #   end
  # 
  #   door = Door.new
  #   door.open
  #   door.is?(:opened) #=> true
  #
  def is?(state_name_or_symbol)
    _synchronize_state
    @ssm_state_machine.current_state.name.to_sym == state_name_or_symbol.to_sym
  end

  # Returns true if the Object is not in the State represented by the name or symbol.
  #
  #   class Door
  #     include SSM
  #
  #     ssm_initial_state :closed
  #     ssm_state :opened
  #
  #     ssm_event :open, :from => [:closed], :to => :opened do
  #       puts "Just opened door"
  #     end
  #     
  #     ssm_event :close, :from => [:opened], :to => :closed do
  #       puts "Closed door"
  #     end
  #
  #   end
  # 
  #   door = Door.new
  #   door.open
  #   door.is?(:closed) #=> false  
  #
  def is_not?(state_name_or_symbol)
    _synchronize_state
    @ssm_state_machine.current_state.name.to_sym != state_name_or_symbol.to_sym
  end
  
  # Returns a symbol representing the current State
  #
  #    door = Door.new
  #    door.ssm_state #=> :closed
  #
  def ssm_state
    _synchronize_state
    @ssm_state_machine.current_state.name  
  end
  
  private

  def _ssm_trigger_event(event_name_or_symbol, args)
    _synchronize_state
    event = @ssm_state_machine.get_event_by_name(event_name_or_symbol)
    
    @ssm_state_machine.transition(event.transition)
    ssm_set(@ssm_state_machine.get_state_for_property) unless @ssm_state_machine.property_name.nil?
    instance_exec *args, &event.block
  end
  
  # instance_exec for 1.8.x
  # http://groups.google.com/group/ruby-talk-google/browse_thread/thread/34bc4c9b2cac3424
  unless instance_methods.include? 'instance_exec' #:nodoc:
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block)
      mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
      InstanceExecHelper.module_eval{ define_method(mname, &block) }
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
  end
  
  def _synchronize_state
    ssm_get.nil? ? ssm_set(@ssm_state_machine.get_state_for_property) : _update_ssm_state unless _state_up_to_date?
    true
  end
  
  # Checks whether the StateMachine and the property in the instance are in sync
  def _state_up_to_date?
    @ssm_state_machine.property_name.nil? ? true : ssm_get == @ssm_state_machine.get_state_for_property
  end
  
  # Updates the StateMachine based on the value of the state property of the instance
  def _update_ssm_state
    unless @ssm_state_machine.property_name.nil?
      @ssm_state_machine.current_state = @ssm_state_machine.use_property_index == true ? @ssm_state_machine.get_state_by_index(ssm_get) : @ssm_state_machine.get_state_by_name(ssm_get)
    end
  end
end
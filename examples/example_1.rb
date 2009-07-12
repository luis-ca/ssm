require File.join(File.dirname(__FILE__), '../lib/ssm')

class Door
  
  include SSM
  
  ssm_initial_state :closed # required
  ssm_state :opened
  
  ssm_event :open, :from => [:closed], :to => :opened do
    print "Opening door... "
    # ...
    puts "door is now open."
  end
  
  ssm_event :close, :from => [:opened], :to => :closed do
    print "Closing door... "
    # ...
    puts "door is now closed."
  end
end

door = Door.new
door.open
puts door.is?(:opened)
door.close

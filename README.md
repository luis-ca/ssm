# SSM - Simple State Machine mixin

SSM is a mixin that adds finite-state machine behavior to a class.

### Installation

    gem sources -a http://gems.github.com
    sudo gem install spoonsix-ssm

### Simple example usage

    class Door
      include SSM

      ssm_initial_state :closed
      ssm_state :opened

      ssm_event :open, :from => [:closed], :to => :opened do
        puts "Just opened door"
      end
  
      ssm_event :close, :from => [:opened], :to => :closed do
        puts "Closed door"
      end

    end

    door = Door.new
    door.open
    door.is?(:opened) #=> true
    door.close
    
### Inspiration and resources

* http://en.wikipedia.org/wiki/Finite-state_machine
* http://github.com/rubyist/aasm
* http://www.ibm.com/developerworks/java/library/j-cb03137/index.html

## License

dog not god: server health monitoring simplified
Copyright (C) 2009 spoonsix - Luis Correa d'Almeida

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

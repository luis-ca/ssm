Gem::Specification.new do |s|
   s.name = %q{ssm}
   s.version = "0.1.6"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{simple state machine is a mixin that adds finite-state machine behavior to a class.}
   s.description = %q{simple state machine is a mixin that adds finite-state machine behavior to a class.}
   s.homepage = %q{http://github.com/spoonsix/ssm}

   s.files = ["lib/event.rb", "lib/ssm.rb", "lib/state.rb", "lib/state_machine.rb", "lib/state_transition.rb"]
end
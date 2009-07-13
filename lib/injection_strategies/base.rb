module SSM

  module InjectionStrategies
    
    class Base
      
      def self.factory(name_as_symbol)
        
        name = name_as_symbol.nil? ? 'object' : name_as_symbol.to_s
        
        location = File.join(File.dirname(__FILE__), "*strategy.rb")
        strategies = Dir[location]
        
        file_from_name = File.join(File.dirname(__FILE__), "#{name}_strategy.rb")

        if strategies.include?(file_from_name)
          require file_from_name
          class_name = "#{name.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }}Strategy" # from ActiveSupport
        else
          require File.join(File.dirname(__FILE__), "object_strategy.rb")
          class_name = "ObjectStrategy"
        end
        SSM::InjectionStrategies.const_get(class_name).new
      end
    end
  end
  
  
end
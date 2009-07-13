module SSM
  module InjectionStrategies
    module ActiveRecordStrategy
    
      # Generic setup
      def ssm_setup
        # sm = @ssm_state_machine
        # unless sm.property_name.nil?
        #   # This allows others to set up the object however they see fit, including mixing in setters.
        #   instance_eval("def #{sm.property_name}; @#{sm.property_name}; end") unless respond_to?(sm.property_name)
        #   instance_eval("def #{sm.property_name}=(v); @#{sm.property_name} = v; end") unless respond_to?("#{sm.property_name}=".to_sym)
        #   
        #   _synchronize_state
        # end
      end
      
      
      def ssm_set(v)
        send("#{@ssm_state_machine.property_name}=".to_sym, v)
      end
      
      def ssm_get
        send("#{@ssm_state_machine.property_name}".to_sym)
      end      
      
    end
  end
end
module SSM
  module InjectionStrategies
    module ActiveRecordStrategy
    
      def ssm_setup
        _synchronize_state if new_record?
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
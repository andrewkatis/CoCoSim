classdef Template_To_Lustre < Block_To_Lustre
    %Test_write a dummy class
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk)
            obj.code = 'You code here';
        end
        
        function getUnsupportedOptions(obj, varargin)
            % add your unsuported options list here
           obj.unsupported_options = {};  
        end
    end
    
end


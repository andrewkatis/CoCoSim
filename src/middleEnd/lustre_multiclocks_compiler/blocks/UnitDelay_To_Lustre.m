classdef UnitDelay_To_Lustre < Block_To_Lustre
    %UnitDelay_To_Lustre.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, varargin)
            [lustre_code, variables, external_libraries, unsupported_options] = ...
                Delay_To_Lustre.get_code( parent, blk, ...
                'Dialog', 'Dialog',...
                '1', 'None', 'off' );
            obj.addVariable(variables);
            obj.addExternal_libraries(external_libraries);
            obj.addUnsupported_options(unsupported_options);
            obj.setCode(lustre_code);
           
        end
        
        function options = getUnsupportedOptions(obj, varargin)
            % add your unsuported options list here
            options = obj.unsupported_options;
        end
    end
    
    
    
end


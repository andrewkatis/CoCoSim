classdef BusToVector_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    % BusToVector_To_Lustre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            L = nasa_toLustre.ToLustreImport.L;
            import(L{:})
            [outputs, outputs_dt] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            obj.addVariable(outputs_dt);
            inputs =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk);
            
            % As we inline following columns, we just pass inputs to outputs
            codes = arrayfun(@(i) LustreEq(outputs{i}, inputs{i}), ...
                (1:numel(outputs)), 'un', 0);
            obj.setCode( codes );
            
        end
        
        function options = getUnsupportedOptions(obj, varargin)
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    

    
end


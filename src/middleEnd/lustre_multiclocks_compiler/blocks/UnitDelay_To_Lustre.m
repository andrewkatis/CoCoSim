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
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            InitialConditionSource = 'Dialog';
            DelayLengthSource = 'Dialog';
            DelayLength = '1';
            DelayLengthUpperLimit = '1';
            ExternalReset = 'None';
            ShowEnablePort = 'off';
            [lustre_code, delay_node_code, variables, external_libraries] = ...
                Delay_To_Lustre.get_code( parent, blk, ...
                InitialConditionSource, DelayLengthSource, DelayLength,...
                DelayLengthUpperLimit, ExternalReset, ShowEnablePort, xml_trace );
            obj.addVariable(variables);
            obj.addExternal_libraries(external_libraries);
            obj.addExtenal_node(delay_node_code);
            obj.setCode(lustre_code);
           
        end
        
        function options = getUnsupportedOptions(obj, varargin)
            % add your unsuported options list here
            options = obj.unsupported_options;
        end
    end
    
    
    
end


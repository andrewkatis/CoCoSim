%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2019 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
classdef LusValidateUtils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static = true)        
        %% from Simulink dataType to Lustre DataType
        function slx_dt = get_slx_dt(lus_dt)
            if iscell(lus_dt)
                slx_dt = cellfun(@(x) LusValidateUtils.get_slx_dt(x), ...
                    lus_dt, 'UniformOutput', 0);
                return;
            end
            if strcmp(lus_dt, 'bool')
                slx_dt = 'boolean';
            elseif strcmp(lus_dt, 'int')
                slx_dt = 'int32';
            elseif strcmp(lus_dt, 'real')
                slx_dt = 'double';
            else
                slx_dt = lus_dt;
            end
        end
      
    end
    
end


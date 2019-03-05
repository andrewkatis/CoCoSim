
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function name = getStateInnerTransNodeName(state)
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    state_name = nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.getUniqueName(state);
    name = strcat(state_name, '_InnerTrans_Node');
end

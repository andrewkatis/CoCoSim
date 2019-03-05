%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function call = changeEvents(call, EventsNames, E)
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    args = call.getArgs();
    inputs_Ids = cellfun(@(x) nasa_toLustre.lustreAst.VarIdExpr(x.getId()), ...
        args, 'UniformOutput', false);
    for i=1:numel(inputs_Ids)
        if isequal(inputs_Ids{i}.getId(), E)
            inputs_Ids{i} = nasa_toLustre.lustreAst.BooleanExpr(true);
        elseif ismember(inputs_Ids{i}.getId(), EventsNames)
            inputs_Ids{i} = nasa_toLustre.lustreAst.BooleanExpr(false);
        end
    end

    call = nasa_toLustre.lustreAst.NodeCallExpr(call.nodeName, inputs_Ids);
end

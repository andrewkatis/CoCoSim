function new_obj = changeArrowExp(obj, cond)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    new_args = cellfun(@(x) x.changeArrowExp(cond), obj.args, 'UniformOutput', 0);
    
    new_obj = nasa_toLustre.lustreAst.NodeCallExpr(obj.nodeName, new_args);
end

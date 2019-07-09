function [code, exp_dt, dim] = andFun_To_Lustre(BlkObj, tree, parent, blk,...
        data_map, inputs, expected_dt, isSimulink, isStateFlow, isMatlabFun)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Francois Conzelmann <francois.conzelmann@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    op = nasa_toLustre.lustreAst.BinaryExpr.AND;
    code = {};
    [x, x_dt, x_dim] = nasa_toLustre.blocks.Stateflow.utils.MExpToLusAST.expression_To_Lustre(BlkObj, tree.parameters(1),...
        parent, blk, data_map, inputs, expected_dt, ...
        isSimulink, isStateFlow, isMatlabFun);
    [y, ~, ~] = nasa_toLustre.blocks.Stateflow.utils.MExpToLusAST.expression_To_Lustre(BlkObj, tree.parameters(2),...
        parent, blk, data_map, inputs, expected_dt, ...
        isSimulink, isStateFlow, isMatlabFun);
    
    for i=1:numel(x)
        code{end+1} = nasa_toLustre.lustreAst.BinaryExpr(op, ...
            x(i), ...
            y(i),...
            false);
    end
    dim = x_dim;
    exp_dt = x_dt;
end


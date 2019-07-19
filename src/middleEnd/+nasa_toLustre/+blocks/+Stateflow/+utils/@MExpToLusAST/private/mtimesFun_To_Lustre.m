function [code, exp_dt, dim] = mtimesFun_To_Lustre(tree, args)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Francois Conzelmann <francois.conzelmann@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [x, x_dt, x_dim] = nasa_toLustre.blocks.Stateflow.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(1),args);
    [y, ~, y_dim] = nasa_toLustre.blocks.Stateflow.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(2), args);
    
    [code, dim] = nasa_toLustre.blocks.Stateflow.utils.MF2LusUtils.mtimesFun_To_Lustre(x, x_dim, y, y_dim);
    
    exp_dt = x_dt;
    
end


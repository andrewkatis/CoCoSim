function [code, exp_dt, dim] = sumFun_To_Lustre(tree, args)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %         Francois Conzelmann <francois.conzelmann@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    code = {};
    op = nasa_toLustre.lustreAst.BinaryExpr.PLUS;
    [x, x_dt, x_dim] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(...
        tree.parameters(1), args);
    n_dim = numel(x_dim);
    x_new = reshape(x, x_dim);
    
    if length(tree.parameters) == 1
        if n_dim > 2
            ME = MException('COCOSIM:TREE2CODE', ...
                'Function sum in expression "%s" first argument is %d-dimension, more than 2 is not supported.',...
                tree.text, numel(x_dim));
            throw(ME);
        else
            if x_dim(1) == 1
                param2_value = 2;
            else
                param2_value = 1;
            end
        end
    else
        param2 = tree.parameters{2};
        if strcmp(param2.type, 'constant')
            param2_value = str2num(param2.value);
        else
            ME = MException('COCOSIM:TREE2CODE', ...
                'Function sum in expression "%s" second argument is not a constant is not supported.',...
                tree.text);
            throw(ME);
        end
    end
    
    if param2_value == 2
        for i=1:x_dim(1)
            code{end+1} = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(op, x_new(i, :));
        end
        dim = [x_dim(1) 1];
        
    elseif param2_value == 1
        for i=1:x_dim(2)
            code{end+1} = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(op, x_new(:, i));
        end
        dim = [1 x_dim(2)];
    else
        ME = MException('COCOSIM:TREE2CODE', ...
            'Function sum in expression "%s" is not supported.',...
            tree.text);
        throw(ME);
    end
    
    exp_dt = x_dt{1};
    

function [code, exp_dt, dim, extra_code] = normFun_To_Lustre(tree, args)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dim = [1 1];
    [~, ~, x_dim, ~] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(1),args);
    if isa(tree.parameters, 'struct')
        params = arrayfun(@(x) x, tree.parameters, 'UniformOutput', 0);
    else
        params = tree.parameters;
    end
    
    x_text = params{1}.text;
    p_text = '2';
    
    if length(params) > 1
        if strcmp(params{2}.type, 'constant')
            p_text = params{2}.text;
        else
            ME = MException('COCOSIM:TREE2CODE', ...
                'Second argument of norm in expression "%s" must be a constant.',...
                tree.text, numel(x_dim));
            throw(ME);
        end
    end
    
    
    if length(x_dim) <= 2 && (x_dim(1) == 1 || x_dim(2) == 1)  % isvector
        switch p_text
            case 'Inf'
                % TODO : support inf arguments
                expr = sprintf("max(abs(%s))", x_text);
            case '-Inf'
                % TODO : support inf arguments
                expr = sprintf("min(abs(%s))", x_text);
            case '1'
                expr = sprintf("sum(abs(%s))", x_text);
            case '2'
                expr = sprintf("sqrt(sum((%s).^2))", x_text);
            otherwise
                expr = sprintf("sum(abs(%s).^%s))^(1/%s)", x_text, p_text, p_text);
        end
    else  % ismatrix
        switch p_text
            case 'Inf'
                % TODO : support inf arguments
                expr = sprintf("max(sum(abs((%s)')))", x_text);
            case "'fro'"
                expr = sprintf("sqrt(trace((%s)'*(%s)))", x_text, x_text);
            case '1'
                expr = sprintf("max(sum(abs(%s)))", x_text);
            case '2'
                % TODO : support this case
                ME = MException('COCOSIM:TREE2CODE', ...
                    'norm in expression "%s" is not supported.',...
                    tree.text, numel(x_dim));
                throw(ME);
            otherwise
                ME = MException('COCOSIM:TREE2CODE', ...
                    'Unexpected case in norm expression "%s"',...
                    tree.text, numel(x_dim));
                throw(ME);
        end
    end
    
    new_tree = MatlabUtils.getExpTree(expr);
    
    [code, exp_dt, dim, extra_code] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(new_tree, args);
    
end
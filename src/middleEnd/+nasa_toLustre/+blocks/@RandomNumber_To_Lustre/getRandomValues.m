function r_str = getRandomValues(r, i)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    if i == numel(r)
        r_str = nasa_toLustre.lustreAst.RealExpr(r(i));
    else
        r_str =nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.ARROW, ...
            nasa_toLustre.lustreAst.RealExpr(r(i)), ...
            nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.PRE,...
            nasa_toLustre.blocks.RandomNumber_To_Lustre.getRandomValues(r, i+1)));

    end
end



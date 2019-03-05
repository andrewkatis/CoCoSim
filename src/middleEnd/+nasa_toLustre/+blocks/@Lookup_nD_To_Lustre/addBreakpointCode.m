function [body,vars,Breakpoints] = ...
        addBreakpointCode(BreakpointsForDimension,blk_name,...
        lusInport_dt,isLookupTableDynamic,inputs,NumberOfTableDimensions)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    % This function define the breakpoints defined by
    % users.
    body = {};
    vars = {};            
    for j = 1:NumberOfTableDimensions
        Breakpoints{j} = {};
        for i=1:numel(BreakpointsForDimension{j})
            Breakpoints{j}{i} = nasa_toLustre.lustreAst.VarIdExpr(...
                sprintf('%s_Breakpoints_dim%d_%d',blk_name,j,i));
            %vars = sprintf('%s\t%s:%s;\n',vars,Breakpoints{j}{i},lusInport_dt);
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(Breakpoints{j}{i},lusInport_dt);
            if ~isLookupTableDynamic
                %body = sprintf('%s\t%s = %.15f ;\n', body, Breakpoints{j}{i}, BreakpointsForDimension{j}(i));
                body{end+1} = nasa_toLustre.lustreAst.LustreEq(Breakpoints{j}{i}, nasa_toLustre.lustreAst.RealExpr(BreakpointsForDimension{j}(i)));
            else
                %body = sprintf('%s\t%s = %s;\n', body, Breakpoints{j}{i}, inputs{2}{i});
                body{end+1} = nasa_toLustre.lustreAst.LustreEq(Breakpoints{j}{i}, inputs{2}{i});
            end

        end
    end
end

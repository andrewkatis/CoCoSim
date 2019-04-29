function [body, vars, direct_lookup_node] = addDirectLookupNodeCode(...
        blkParams,index_node,coords_node, coords_input ,...
        Ast_dimJump,lus_backend,Breakpoints)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % This function carries out the interpolation depending on algorithm
    % option.  For the flat option, the value at the lower bounding
    % breakpoint is used. For the nearest option, the closest
    % bounding node for each dimension is used.  For the above option, the 
    % value at the upper bounding breakpoint is used.  We are not
    % calculating the distance from the interpolated point to each
    % of the bounding node on the polytop containing the
    % interpolated point.  For the "clipped" extrapolation option, the nearest
    % breakpoint in each dimension is used. Cubic spline is not
    % supported
    InterpMethod = blkParams.InterpMethod;
    NumberOfTableDimensions = blkParams.NumberOfAdjustedTableDimensions;
    BreakpointsForDimension = blkParams.BreakpointsForDimension;            
    body = {};
    vars = {};
    direct_lookup_node{1} = ...
        nasa_toLustre.lustreAst.VarIdExpr('direct_lookup_node_inline_index');
    vars{end+1} = nasa_toLustre.lustreAst.LustreVar(...
        direct_lookup_node{1}, 'int');
    solutionArrayIndex = cell(1,NumberOfTableDimensions);
    for i=1:NumberOfTableDimensions
        % create variable for current array index
        solutionArrayIndex{i} = ...
            nasa_toLustre.lustreAst.VarIdExpr(...
            sprintf('array_index_solution_dim_%d',i));
        vars{end+1} = nasa_toLustre.lustreAst.LustreVar(...
            solutionArrayIndex{i}, 'int');
        
        if ~nasa_toLustre.utils.LookupType.isLookupDynamic(blkParams.lookupTableType)
            epsilon = ...
                nasa_toLustre.blocks.Lookup_nD_To_Lustre.calculate_eps(...
                BreakpointsForDimension{i}, 1);
        end
        
        if strcmp(InterpMethod,'Flat')
            % if coordinate is at higher boundary node then use higher
            % node, else use lower node    
            if nasa_toLustre.utils.LookupType.isLookupDynamic(blkParams.lookupTableType)
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.GTE, ...
                    coords_input{i},coords_node{i,2},[], ...
                    LusBackendType.isLUSTREC(lus_backend));                
            else
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.GTE, ...
                    coords_input{i},coords_node{i,2},[], ...
                    LusBackendType.isLUSTREC(lus_backend), epsilon);
            end
            
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(...                 
                solutionArrayIndex{i}, nasa_toLustre.lustreAst.IteExpr(...
                condition,index_node{i,2},index_node{i,1}));
            
        elseif strcmp(InterpMethod,'Above')
            % if coordinate at lower boundary node then use lower
            % node, else use higher node     
            if nasa_toLustre.utils.LookupType.isLookupDynamic(blkParams.lookupTableType)
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.EQ, ...
                    coords_node{i,1},...
                    coords_input{i}, [], ...
                    LusBackendType.isLUSTREC(lus_backend));                
            else
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.EQ, ...
                    coords_node{i,1},...
                    coords_input{i}, [], ...
                    LusBackendType.isLUSTREC(lus_backend), epsilon);
            end
            
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(...                 
                solutionArrayIndex{i}, nasa_toLustre.lustreAst.IteExpr(...
                condition,index_node{i,1},index_node{i,2}));
        else
            % 'Nearest' case, the closest bounding node for each dimension
            % is used.
            disFromTableNode{1} = ...
                nasa_toLustre.lustreAst.VarIdExpr(...
                sprintf('disFromTableNode_dim_%d_1',i));
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(...
                disFromTableNode{1},'real');
            disFromTableNode{2} = ...
                nasa_toLustre.lustreAst.VarIdExpr(...
                sprintf('disFromTableNode_dim_%d_2',i));
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(...
                disFromTableNode{2},'real');
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(...
                disFromTableNode{1},...
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.MINUS,...
                coords_input{i},coords_node{i,1}));            
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(...
                disFromTableNode{2},...
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.MINUS,...
                coords_node{i,2},coords_input{i}));
            if nasa_toLustre.utils.LookupType.isLookupDynamic(blkParams.lookupTableType)
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.LTE, ...
                    disFromTableNode{1},...
                    disFromTableNode{2}, [], ...
                    LusBackendType.isLUSTREC(lus_backend));                
            else
                condition =  ...
                    nasa_toLustre.lustreAst.BinaryExpr(...
                    nasa_toLustre.lustreAst.BinaryExpr.LTE, ...
                    disFromTableNode{1},...
                    disFromTableNode{2}, [], ...
                    LusBackendType.isLUSTREC(lus_backend), epsilon);
            end
            
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(...
                solutionArrayIndex{i}, nasa_toLustre.lustreAst.IteExpr(...
                condition,index_node{i,1},index_node{i,2}));
        end
    end
    
    % calculating inline index from array indices
    terms = cell(1,NumberOfTableDimensions);
    for j=1:NumberOfTableDimensions
        if j==1
            terms{j} = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,...
                solutionArrayIndex{j}, Ast_dimJump{j});
        else
            terms{j} = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,...
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.MINUS,...
                solutionArrayIndex{j},...
                nasa_toLustre.lustreAst.IntExpr(1)), ...
                Ast_dimJump{j});
        end
    end

    if NumberOfTableDimensions == 1
        rhs = terms{1};
    elseif NumberOfTableDimensions == 2
        rhs = nasa_toLustre.lustreAst.BinaryExpr(...
            nasa_toLustre.lustreAst.BinaryExpr.PLUS,terms{1},terms{2});
    else
        rhs = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(...
            nasa_toLustre.lustreAst.BinaryExpr.PLUS,terms);
    end
    body{end+1} = nasa_toLustre.lustreAst.LustreEq(direct_lookup_node{1},rhs);
    
end


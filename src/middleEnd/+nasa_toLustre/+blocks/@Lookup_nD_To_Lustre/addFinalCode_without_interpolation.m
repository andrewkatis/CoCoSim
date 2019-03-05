function [body, vars] = addFinalCode_without_interpolation(...
        outputs,inputs,indexDataType,blk_name,...
        blkParams,...
        coords_node,lusInport_dt,...
        index_node,Ast_dimJump,table_elem, lus_backend)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
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
    NumberOfTableDimensions = blkParams.NumberOfTableDimensions;
    BreakpointsForDimension = blkParams.BreakpointsForDimension;            
    body = {};
    vars = {};
    returnTableIndex{1} =  nasa_toLustre.lustreAst.VarIdExpr(sprintf('%s_retTableInd_%d',blk_name,1));
    vars{end+1} = nasa_toLustre.lustreAst.LustreVar(returnTableIndex{1}, indexDataType);
    terms = cell(1,NumberOfTableDimensions);
    if strcmp(InterpMethod,'Flat')
        % defining returnTableIndex{1}
        %value = '0';
        %value_n = IntExpr(0);
        for j=1:NumberOfTableDimensions
            curIndex =  index_node{j,1};
            if j==1
                terms{j} = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,curIndex, Ast_dimJump{j});
            else
                terms{j} = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,curIndex,nasa_toLustre.lustreAst.IntExpr(1)), Ast_dimJump{j});
            end
        end
    elseif strcmp(InterpMethod,'Above')
        % defining returnTableIndex{2} if input value is not at lower bounding breakpoint
        for j=1:NumberOfTableDimensions
            % check to see if input is at lower bounding node,
            % if it is then curIndex equal lower bounding
            % breakpoint, otherwise it is at higher bounding
            % breakpoint
            curIndex1 =  index_node{j,1};
            curIndex2 =  index_node{j,2};
            if blkParams.isLookupTableDynamic
                cond = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.LTE,inputs{j}{1},coords_node{j,1}, [], LusBackendType.isLUSTREC(lus_backend));
            else
                epsilon = 1.e-15;
                cond = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.LTE,inputs{j}{1},coords_node{j,1}, [], LusBackendType.isLUSTREC(lus_backend), epsilon);
            end
            if j==1
                terms{j} = nasa_toLustre.lustreAst.IteExpr(cond,nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,curIndex1, Ast_dimJump{j}),...
                    nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,curIndex2, Ast_dimJump{j}));
            else
                terms{j} = nasa_toLustre.lustreAst.IteExpr(cond,nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,...
                    nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,curIndex1,nasa_toLustre.lustreAst.IntExpr(1)), Ast_dimJump{j}),...
                    nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,curIndex2,nasa_toLustre.lustreAst.IntExpr(1)), Ast_dimJump{j}));
            end
        end
    else   % 'Nearest' case
        % defining returnTableIndex{1}
        disFromTableNode = cell(NumberOfTableDimensions,2);
        nearestIndex = cell(1,NumberOfTableDimensions);
        for i=1:NumberOfTableDimensions
            disFromTableNode{i,1} = nasa_toLustre.lustreAst.VarIdExpr(sprintf('%s_disFromTableNode_dim_%d_1',blk_name,i));
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(disFromTableNode{i,1},lusInport_dt);
            disFromTableNode{i,2} = nasa_toLustre.lustreAst.VarIdExpr(sprintf('%s_disFromTableNode_dim_%d_2',blk_name,i));
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(disFromTableNode{i,2},lusInport_dt);
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(disFromTableNode{i,1},nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,inputs{i}{1},coords_node{i,1}));
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(disFromTableNode{i,2},nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,coords_node{i,2},inputs{i}{1}));

            nearestIndex{i} = nasa_toLustre.lustreAst.VarIdExpr(sprintf('%s_nearestIndex_dim_%d',blk_name,i));
            vars{end+1} = nasa_toLustre.lustreAst.LustreVar(nearestIndex{i},indexDataType);
            if blkParams.isLookupTableDynamic
                condC = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.LTE,disFromTableNode{i,2},disFromTableNode{i,1}, [], LusBackendType.isLUSTREC(lus_backend));
            else
                epsilon = nasa_toLustre.blocks.Lookup_nD_To_Lustre.calculate_eps(BreakpointsForDimension{i}, 2);
                condC = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.LTE,disFromTableNode{i,2},disFromTableNode{i,1}, [], LusBackendType.isLUSTREC(lus_backend), epsilon);
            end
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(nearestIndex{i},nasa_toLustre.lustreAst.IteExpr(condC,index_node{i,2},index_node{i,1}));
        end

        %value = '0';
        for j=1:NumberOfTableDimensions
            if j==1
                %value = sprintf('%s + %s*%d',value,nearestIndex{j}, dimJump(j));
                terms{j} = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,nearestIndex{j}, Ast_dimJump{j});
            else
                %value = sprintf('%s + (%s-1)*%d',value,nearestIndex{j}, dimJump(j));
                terms{j} = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MINUS,nearestIndex{j},nasa_toLustre.lustreAst.IntExpr(1)), Ast_dimJump{j});
            end
        end
    end
    if NumberOfTableDimensions == 1
        rhs = terms{1};
    elseif NumberOfTableDimensions == 2
        rhs = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.PLUS,terms{1},terms{2});
    else
        rhs = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(nasa_toLustre.lustreAst.BinaryExpr.PLUS,terms);
    end
    body{end+1} = nasa_toLustre.lustreAst.LustreEq(returnTableIndex{1},rhs);

    % defining outputs{1}
    conds = cell(1,numel(table_elem)-1);
    thens = cell(1,numel(table_elem));
    for j=1:numel(table_elem)-1
        conds{j} = nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.EQ,returnTableIndex{1},nasa_toLustre.lustreAst.IntExpr(j));
        thens{j} = table_elem{j};
        %                     if j==1
        %                         code = sprintf('%s  if(%s = %d) then %s\n\t', code, returnTableIndex{1},j,table_elem{j});
        %                     else
        %                         code = sprintf('%s  else if(%s = %d) then %s\n\t', code, returnTableIndex{1},j,table_elem{j});
        %                     end
    end
    thens{numel(table_elem)} = table_elem{numel(table_elem)};
    if numel(table_elem) == 1
        rhs = nasa_toLustre.lustreAst.IteExpr(conds{1},thens{1},thens{2});
    else
        rhs = nasa_toLustre.lustreAst.IteExpr.nestedIteExpr(conds, thens);
    end
    body{end+1} = nasa_toLustre.lustreAst.LustreEq(outputs{1},rhs);
end


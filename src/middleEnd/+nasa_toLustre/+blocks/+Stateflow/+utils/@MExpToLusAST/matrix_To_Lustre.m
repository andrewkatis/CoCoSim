function [code, dt] = matrix_To_Lustre(BlkObj, tree, parent, blk, data_map,...
        inputs, ~, isSimulink, isStateFlow)
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    import nasa_toLustre.blocks.Stateflow.utils.*
    dt = MExpToLusDT.expression_DT(tree, data_map, inputs, isSimulink, isStateFlow);
    
    if isstruct(tree.rows)
        rows = arrayfun(@(x) x, tree.rows, 'UniformOutput', false);
    else
        rows = tree.rows;
    end
    
    nb_rows = numel(rows);
    nb_culomns = numel(rows{1});
    
    if ischar(dt)
        code_dt = arrayfun(@(i) dt, ...
            (1:nb_rows*nb_culomns), 'UniformOutput', false);
    elseif iscell(dt) && numel(dt) < nb_rows*nb_culomns
        code_dt = arrayfun(@(i) dt{1}, ...
            (1:nb_rows*nb_culomns), 'UniformOutput', false);
    else
        code_dt = dt;
    end
    
    code = {};
    code_dt = reshape(code_dt, nb_rows, nb_culomns);
    for i=1:nb_rows
        columns = rows{i};
        for j=1:numel(columns)
            code(end+1) =...
                MExpToLusAST.expression_To_Lustre(BlkObj, columns(j), ...
                parent, blk, data_map, inputs, code_dt{i, j},...
                isSimulink, isStateFlow);
        end
    end
    
    
end
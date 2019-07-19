function [fun_node,failed ]  = getFuncCode(func, data_map, blkObj, parent, blk)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global VISITED_VARIABLES;
    VISITED_VARIABLES = {};
    statements = func.statements;
    expected_dt = '';
    isSimulink = false;
    isStateFlow = false;
    isMatlabFun = true;
    variables = {};
    body = {};
    failed = false;
    
    
    
    for i=1:length(statements)
        if isstruct(statements)
            s = statements(i);
        else
            s = statements{i};
        end
        try
            args.blkObj = blkObj;
            args.blk = blk;
            args.parent = parent;
            args.data_map = data_map;
            args.expected_lusDT = expected_dt;
            args.isSimulink = false;
            args.isStateFlow = false;
            args.isMatlabFun = true;
            lusCode = nasa_toLustre.blocks.Stateflow.utils.MExpToLusAST.expression_To_Lustre(s, args);
            [vars, ~] = nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.getInOutputsFromAction(lusCode, ...
                false, data_map, s.text);
            variables = MatlabUtils.concat(variables, vars);
            body = MatlabUtils.concat(body, lusCode);
        catch me
            if strcmp(me.identifier, 'COCOSIM:STATEFLOW')
                display_msg(me.message, MsgType.WARNING, 'getMFunctionCode', '');
            else
                display_msg(me.getReport(), MsgType.DEBUG, 'getMFunctionCode', '');
            end
            display_msg(sprintf('Statement "%s" failed for block %s', ...
                s.text, HtmlItem.addOpenCmd(blk.Origin_path)),...
                MsgType.WARNING, 'getMFunctionCode', '');
            failed = true;
        end
    end
    [fun_node] = nasa_toLustre.frontEnd.MF_To_LustreNode.getFunHeader(func, blk, data_map);
    node_outputs = fun_node.getOutputs();
    variables = nasa_toLustre.lustreAst.LustreVar.uniqueVars(variables);
    variables = nasa_toLustre.lustreAst.LustreVar.setDiff(variables, node_outputs);
    fun_node.setLocalVars(variables);
    fun_node.setBodyEqs(body);
    fun_node = fun_node.pseudoCode2Lustre();
end

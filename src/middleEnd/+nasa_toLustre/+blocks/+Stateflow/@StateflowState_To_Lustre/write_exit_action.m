%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXIT ACTION
function [main_node, external_libraries] = ...
        write_exit_action(state, data_map)
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    import nasa_toLustre.blocks.Stateflow.utils.*
    global SF_STATES_NODESAST_MAP SF_STATES_PATH_MAP;
    external_libraries = {};
    main_node = {};
    body = {};
    outputs = {};
    inputs = {};
    variables = {};
    parentName = fileparts(state.Path);
    if isempty(parentName)
        %main chart
        return;
    end
    %get stateEnumType
    idStateName = nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.getStateIDName(state);
    [stateEnumType, stateInactive] = ...
        nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.addStateEnum(state, [], ...
        false, false, true);

    % history junctions
    junctions = state.Composition.SubJunctions;
    typs = cellfun(@(x) x.Type, junctions, 'UniformOutput', false);
    hjunctions = junctions(strcmp(typs, 'HISTORY'));
    if ~isempty(hjunctions)
        variables{end+1} = nasa_toLustre.lustreAst.LustreVar('_HistoryJunction', stateEnumType);
        body{end+1} = nasa_toLustre.lustreAst.LustreEq(nasa_toLustre.lustreAst.VarIdExpr('_HistoryJunction'),...
            nasa_toLustre.lustreAst.VarIdExpr(idStateName));
    end
    %write children states exit action
    [actions, outputs_i, inputs_i] = ...
        nasa_toLustre.blocks.Stateflow.StateflowState_To_Lustre.write_children_actions(state, 'Exit');
    body = [body, actions];
    outputs = [outputs, outputs_i];
    inputs = [inputs, inputs_i];

    %isInner variable that tells if the transition that cause this
    %exit action is an inner Transition
    isInner = nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.isInnerStr());

    %actions code
    actions = nasa_toLustre.IR_pp.stateflow_IR_pp.SFIRPPUtils.split_actions(state.Actions.Exit);
    nb_actions = numel(actions);
    for i=1:nb_actions
        try
            [lus_action, outputs_i, inputs_i, external_libraries_i] = ...
                nasa_toLustre.blocks.Stateflow.utils.getPseudoLusAction(actions{i}, data_map, false, state.Path);
            outputs = [outputs, outputs_i];
            inputs = [inputs, inputs_i, outputs_i];
            external_libraries = [external_libraries, external_libraries_i];
            new_assignements = nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.addInnerCond(lus_action, isInner, actions{i}, state);
            body = MatlabUtils.concat(body, new_assignements);
        catch me
            if strcmp(me.identifier, 'COCOSIM:STATEFLOW')
                display_msg(me.message, MsgType.ERROR, 'write_exit_action', '');
            else
                display_msg(me.getReport(), MsgType.DEBUG, 'write_exit_action', '');
            end
            display_msg(sprintf('Exit Action failed for state %s', ...
                state.Origin_path),...
                MsgType.ERROR, 'write_exit_action', '');
        end
    end

    %set state as inactive
    if ~isKey(SF_STATES_PATH_MAP, parentName)
        ME = MException('COCOSIM:STATEFLOW', ...
            'COMPILER ERROR: Not found state "%s" in SF_STATES_PATH_MAP', parentName);
        throw(ME);
    end


    state_parent = SF_STATES_PATH_MAP(parentName);
    idParentName = nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.getStateIDName(state_parent);
    [parentEnumType, parentInactive] = ...
            nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.addStateEnum(state_parent, [], ...
            false, false, true);
    body{end + 1} = nasa_toLustre.lustreAst.LustreComment('set state as inactive');
    % idParentName = if (not isInner) then 0 else idParentName;
    body{end + 1} = nasa_toLustre.lustreAst.LustreEq(nasa_toLustre.lustreAst.VarIdExpr(idParentName), ...
        nasa_toLustre.lustreAst.IteExpr(nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.NOT, isInner), ...
        parentInactive, nasa_toLustre.lustreAst.VarIdExpr(idParentName)));
    outputs{end + 1} = nasa_toLustre.lustreAst.LustreVar(idParentName, parentEnumType);
    inputs{end + 1} = nasa_toLustre.lustreAst.LustreVar(idParentName, parentEnumType);
    % add isInner input
    inputs{end + 1} = nasa_toLustre.lustreAst.LustreVar(isInner, 'bool');
    % set state children as inactive

    if ~isempty(state.Composition.Substates)  
        if ~isempty(hjunctions)
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(nasa_toLustre.lustreAst.VarIdExpr(idStateName), ...
                nasa_toLustre.lustreAst.VarIdExpr('_HistoryJunction'));
        else
            body{end+1} = nasa_toLustre.lustreAst.LustreEq(nasa_toLustre.lustreAst.VarIdExpr(idStateName), stateInactive);
            outputs{end+1} = nasa_toLustre.lustreAst.LustreVar(idStateName, stateEnumType);
        end
    end

    %create the node
    act_node_name = ...
        nasa_toLustre.blocks.Stateflow.utils.SF2LusUtils.getExitActionNodeName(state);
    main_node = nasa_toLustre.lustreAst.LustreNode();
    main_node.setName(act_node_name);
    comment = nasa_toLustre.lustreAst.LustreComment(...
        sprintf('Exit action of state %s',...
        state.Origin_path), true);
    main_node.setMetaInfo(comment);
    main_node.setBodyEqs(body);
    outputs = nasa_toLustre.lustreAst.LustreVar.uniqueVars(outputs);
    inputs = nasa_toLustre.lustreAst.LustreVar.uniqueVars(inputs);
    main_node.setOutputs(outputs);
    main_node.setInputs(inputs);
    SF_STATES_NODESAST_MAP(act_node_name) = main_node;
end


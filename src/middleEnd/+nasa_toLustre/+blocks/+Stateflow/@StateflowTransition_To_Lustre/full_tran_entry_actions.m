
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Entry actions
function [body, outputs, inputs, antiCondition] = ...
        full_tran_entry_actions(transitions, parentPath, trans_cond, isHJ)
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    global SF_STATES_NODESAST_MAP SF_STATES_PATH_MAP;
    body = {};
    outputs = {};
    inputs = {};
    antiCondition = trans_cond;
    last_destination = transitions{end}.Destination;
    if isHJ
        dest_parent = StateflowTransition_To_Lustre.getParent(...
            last_destination);
    else
        dest_parent = SF_STATES_PATH_MAP(last_destination.Name);
    end
    first_source = transitions{1}.Source;
    if ~strcmp(dest_parent.Path, parentPath)
        %Go to the same level of the destination.
        while ~StateflowTransition_To_Lustre.isParent(...
                StateflowTransition_To_Lustre.getParent(dest_parent),...
                first_source)
            child = dest_parent;
            dest_parent = ...
                StateflowTransition_To_Lustre.getParent(dest_parent);

            % set the child as active, so when the parent execute
            % entry action, it will enter the right child.
            if isHJ
                continue;
            end
            idParentName = SF2LusUtils.getStateIDName(...
                dest_parent);
            [idParentEnumType, idParentStateEnum] = ...
                SF2LusUtils.addStateEnum(dest_parent, child);
            body{end + 1} = LustreComment(...
                sprintf('set state %s as active', child.Name));
            if isempty(trans_cond)
                body{end + 1} = LustreEq(VarIdExpr(idParentName), ...
                    idParentStateEnum);
                outputs{end + 1} = LustreVar(idParentName, idParentEnumType);
            else
                body{end+1} = LustreEq(VarIdExpr(idParentName), ...
                    IteExpr(trans_cond, idParentStateEnum, ...
                    VarIdExpr(idParentName)));
                outputs{end + 1} = LustreVar(idParentName, idParentEnumType);
                inputs{end+1} = LustreVar(idParentName, idParentEnumType);
            end

        end
        if isequal(dest_parent.Composition.Type,'AND')
            %Parallel state Enter.
            parent = ...
                StateflowTransition_To_Lustre.getParent(dest_parent);
            siblings = SF_To_LustreNode.orderObjects(...
                SF2LusUtils.getSubStatesObjects(parent), ...
                'ExecutionOrder');
            nbrsiblings = numel(siblings);
            for i=1:nbrsiblings
                %if nbrsiblings{i}.Id == dest_parent.Id
                    %our parallel state we are entering
                %end
                entryNodeName = ...
                    SF2LusUtils.getEntryActionNodeName(siblings{i});
                if isKey(SF_STATES_NODESAST_MAP, entryNodeName)
                    %entry Action exists.
                    actionNodeAst = SF_STATES_NODESAST_MAP(entryNodeName);
                    [call, oututs_Ids] = actionNodeAst.nodeCall(true, BooleanExpr(false));
                    if isempty(trans_cond)
                        body{end+1} = LustreEq(oututs_Ids, call);
                        outputs = [outputs, actionNodeAst.getOutputs()];
                        inputs = [inputs, actionNodeAst.getInputs()];
                    else
                        body{end+1} = LustreEq(oututs_Ids, ...
                            IteExpr(trans_cond, call, TupleExpr(oututs_Ids)));
                        outputs = [outputs, actionNodeAst.getOutputs()];
                        inputs = [inputs, actionNodeAst.getOutputs()];
                        inputs = [inputs, actionNodeAst.getInputs()];
                    end
                end

            end
        else
            %Not Parallel state Entry
            entryNodeName = ...
                SF2LusUtils.getEntryActionNodeName(dest_parent);
            if isKey(SF_STATES_NODESAST_MAP, entryNodeName)
                actionNodeAst = SF_STATES_NODESAST_MAP(entryNodeName);
                [call, oututs_Ids] = actionNodeAst.nodeCall(true, BooleanExpr(false));
                if isempty(trans_cond)
                    body{end+1} = LustreEq(oututs_Ids, call);
                    outputs = [outputs, actionNodeAst.getOutputs()];
                    inputs = [inputs, actionNodeAst.getInputs()];
                else
                    body{end+1} = LustreEq(oututs_Ids, ...
                        IteExpr(trans_cond, call, TupleExpr(oututs_Ids)));
                    outputs = [outputs, actionNodeAst.getOutputs()];
                    inputs = [inputs, actionNodeAst.getOutputs()];
                    inputs = [inputs, actionNodeAst.getInputs()];
                end
            end
        end
    else
        % this is a case of inner transition where the destination is
        %the parent state. We should not execute entry state of the parent

        if ~isHJ
            idState = SF2LusUtils.getStateIDName(...
                dest_parent);
            [idStateEnumType, idStateInactiveEnum] = ...
                SF2LusUtils.addStateEnum(dest_parent, [], ...
                false, false, true);
            body{end + 1} = LustreComment(...
                sprintf('set state %s as inactive', dest_parent.Name));
            if isempty(trans_cond)
                body{end + 1} = LustreEq(VarIdExpr(idState), ...
                    idStateInactiveEnum);
                outputs{end + 1} = LustreVar(idState, idStateEnumType);
            else
                body{end+1} = LustreEq(VarIdExpr(idState), ...
                    IteExpr(trans_cond, idStateInactiveEnum, ...
                    VarIdExpr(idState)));
                outputs{end + 1} = LustreVar(idState, idStateEnumType);
                inputs{end+1} = LustreVar(idState, idStateEnumType);
            end
        end
        entryNodeName = ...
            SF2LusUtils.getEntryActionNodeName(dest_parent);
        if isKey(SF_STATES_NODESAST_MAP, entryNodeName)
            actionNodeAst = SF_STATES_NODESAST_MAP(entryNodeName);
            [call, oututs_Ids] = actionNodeAst.nodeCall(true, BooleanExpr(true));
            if isempty(trans_cond)
                body{end+1} = LustreEq(oututs_Ids, call);
                outputs = [outputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getInputs()];
            else
                body{end+1} = LustreEq(oututs_Ids, ...
                    IteExpr(trans_cond, call, TupleExpr(oututs_Ids)));
                outputs = [outputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getInputs()];
            end
        end
    end
    %remove isInner input from the node inputs
    inputs_name = cellfun(@(x) x.getId(), ...
        inputs, 'UniformOutput', false);
    inputs = inputs(~strcmp(inputs_name, ...
        SF_To_LustreNode.isInnerStr()));
end

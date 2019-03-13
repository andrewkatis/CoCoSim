%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% transform input struct to lustre format (inlining values)
function [lustre_input_values, status] = getLustreInputValuesFormat(...
        input_dataSet, time, node_struct)
    nb_steps = length(time);
    %number_of_inputs_For_AllSimulation = LustrecUtils.getNumberOfInputsInlinedFromDataSet(input_dataSet, nb_steps);
    number_of_inputs  = input_dataSet.numElements;
    status = 0;
    lustre_input_values = [];
    addTimeStep = false;
    addnbStep = false;
    if nargin >= 3
        node_inputs = node_struct.inputs;
        if length(node_inputs) > number_of_inputs
            % lustrec node_struct replace "__" in the begining of variable name to 'xx'
            time_stepVarName  = regexprep(nasa_toLustre.utils.SLX2LusUtils.timeStepStr(), ...
                '^__', 'xx');
            nbStepStrVarName = regexprep(nasa_toLustre.utils.SLX2LusUtils.nbStepStr(), ...
                '^__', 'xx');
            if length(node_inputs) == number_of_inputs + 2 ...
                    && strcmp(node_inputs(end-1).name, time_stepVarName)...
                    && strcmp(node_inputs(end).name, nbStepStrVarName)
                %additional time_step and nb_step inputs
                addTimeStep = true;
                addnbStep = true;
                timestep = time;
                nbstepValues = (0:nb_steps-1);
            else
                % has clock inputs. Not supported for the moment.
                display_msg('Number of inputs in Lustre node does not match the number of inputs in Simulink', ...
                    MsgType.ERROR, 'LustrecUtils.getLustreInputValuesFormat', '');
                status = 1;
                return;
            end
        end
    end
    % Translate input_stract to lustre format (inline the inputs)
    if number_of_inputs>=1
        %lustre_input_values = ones(number_of_inputs_For_AllSimulation,1);
        lustre_input_values = [];
        for i=1:nb_steps
            for j=1:numel(input_dataSet.getElementNames)
                %[signal_values, width] = LustrecUtils.inline_array(input_dataSet.signals(j), i-1);
                signal_values = LustrecUtils.getSignalValuesInlinedUsingTime(input_dataSet{j}.Values, time(i));
                width = length(signal_values);
                lustre_input_values(end+1:end+width) = signal_values;
            end
            if addTimeStep
                lustre_input_values(end+1) = timestep(i);
            end
            if addnbStep
                lustre_input_values(end+1) = nbstepValues(i);
            end
        end
        
    else
        % virtual inputs :_virtual:bool
        lustre_input_values = ones(1*nb_steps,1);
    end
end

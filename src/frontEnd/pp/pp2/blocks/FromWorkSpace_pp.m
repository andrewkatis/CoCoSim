function [status, errors_msg] = FromWorkSpace_pp(model)
    % FromWorkSpace_pp searches for FromWorkSpace_pp blocks and replaces them by a
    % PP-friendly equivalent.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Processing FromWorkSpace blocks
    % fromWorkSpace_list = find_system(model,...
    %     'LookUnderMasks', 'all', 'MaskType','From WorkSpace block');
    status = 0;
    errors_msg = {};
    fromWorkSpace_list = find_system(model, ...
        'LookUnderMasks', 'all', 'BlockType','FromWorkspace');

    % fromWorkSpace_list = find_system(model,...
    %     'LookUnderMasks', 'all', 'MaskType','From Workspace block');
    if not(isempty(fromWorkSpace_list))
        display_msg('Replacing From Work Space blocks...', MsgType.INFO,...
            'FromWorkSpace_pp', '');

        %% pre-processing blocks
        for i=1:length(fromWorkSpace_list)
            try

                try
                    % checking if the parent is not signal Builder.
                    parent = get_param(fromWorkSpace_list{i}, 'Parent');
                    parent_msktype = get_param(parent, 'MaskType');
                    if isequal(parent_msktype, 'Sigbuilder block')
                        continue;
                    end
                catch
                end

                display_msg(fromWorkSpace_list{i}, MsgType.INFO, ...
                    'FromWorkSpace_pp', '');

                VariableName = get_param(fromWorkSpace_list{i},'VariableName');
                [VariableName_value, ~, status] = SLXUtils.evalParam(...
                    model, ...
                    get_param(fromWorkSpace_list{i}, 'Parent'), ...
                    fromWorkSpace_list{i}, ...
                    VariableName);
                if status
                    display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                        VariableName, fromWorkSpace_list{i}), ...
                        MsgType.ERROR, 'FromWorkSpace_pp', '');
                    continue;
                end

                % assume VariableName_value is a 2D matrix
                variableMatrix = VariableName_value;
                % convert timeseries
                if isa(VariableName_value,'timeseries')
                    [n,m] = size(VariableName_value.Data);
                    variableMatrix = zeros(n,m+1);
                    variableMatrix(:,1) = VariableName_value.Time;
                    variableMatrix(:,2:m+1) = VariableName_value.Data; 
                % convert structure
                elseif isstruct(VariableName_value)
                    [n,m] = size(VariableName_value.signals.values);
                    variableMatrix = zeros(n,m+1);
                    variableMatrix(:,1) = VariableName_value.time;
                    variableMatrix(:,2:m+1) = VariableName_value.signals.values;                 
                end
                % if vector input, then we will let FromWorkSpace_To_Lustre
                % handle it
                [n,m] = size(variableMatrix);
                if m > 2
                    display_msg(sprintf('FromWorkSpace block %s will be handled through Lustre translation and not through pre-processing',...
                        fromWorkSpace_list{i}), ...
                        MsgType.INFO, 'FromWorkSpace_pp', '');
                    continue;
                end                
                % if value at time 0 is not given
                if variableMatrix(1,1) ~= 0
                    new_value = zeros(1, m);
                    variableMatrix = [new_value; variableMatrix];
                end
                SampleTime = get_param(fromWorkSpace_list{i},'SampleTime');
                [SampleTime_value, ~, status] = SLXUtils.evalParam(...
                    model, ...
                    get_param(fromWorkSpace_list{i}, 'Parent'), ...
                    fromWorkSpace_list{i}, ...
                    SampleTime);
                if status
                    display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                        SampleTime, fromWorkSpace_list{i}), ...
                        MsgType.ERROR, 'FromWorkSpace_pp', '');
                    continue;
                end
                outputDataType = get_param(fromWorkSpace_list{i}, 'OutDataTypeStr');
                Interpolate = get_param(fromWorkSpace_list{i},'Interpolate');
                OutputAfterFinalValue = get_param(fromWorkSpace_list{i},'OutputAfterFinalValue');

                PPUtils.replace_one_block(fromWorkSpace_list{i},fullfile('pp_lib','FromWorkSpace'));
                % set digital clock sample time
                % The block 'FromWorkSpace_1_PP/From Workspace/D' does not permit continuous sample
                % time (0 or [0,0]) for the parameter 'SampleTime'.
                if abs(SampleTime_value - 0.0) < 0.000001
                    SampleTime_value_str = '-1';
                else
                    SampleTime_value_str = num2str(SampleTime_value);
                end
                %SampleTime_value = 0.2;
                set_param(strcat(fromWorkSpace_list{i},'/D'),...
                    'SampleTime',SampleTime_value_str);

                [n,m] = size(variableMatrix);
                % set LookupTable interpolation method
                InterpMethod = 'Flat';
                if strcmp(Interpolate, 'on')
                    InterpMethod = 'Linear';
                end
                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'InterpMethod',InterpMethod);
                OutDataTypeReplaceStr = outputDataType;
                if strcmp(outputDataType,'Inherit: auto')
                    OutDataTypeReplaceStr = 'Inherit: Inherit from table data';
                elseif strcmp(outputDataType,'boolean')
                    msg = sprintf('FromWorkSpace pre-processing does not support Boolean output in block %s.', fromWorkSpace_list{i});
                    display_msg(msg, MsgType.DEBUG, 'FromWorkSpace', '');
                    status = 1;
                    errors_msg{end + 1} = msg;
                    continue;
                elseif strcmp(outputDataType,'Enum: <class name>')
                    msg = sprintf('FromWorkspace pre-process has failed for block %s', fromWorkSpace_list{i});
                    display_msg(msg, MsgType.DEBUG, 'FromWorkSpace', '');
                    status = 1;
                    errors_msg{end + 1} = msg;
                    continue;
                elseif strcmp(outputDataType,'Bus: <object name>')
                    msg = sprintf('FromWorkspace pre-process has failed for block %s', fromWorkSpace_list{i});
                    display_msg(msg, MsgType.DEBUG, 'FromWorkSpace', '');
                    status = 1;
                    errors_msg{end + 1} = msg;
                    continue;
                end

                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'OutDataTypeStr',OutDataTypeReplaceStr);
                % ExtrapMethod
                ExtrapMethod = 'Linear';  % extrapolation
                if strcmp(OutputAfterFinalValue, 'Cyclic repetition')
                    % not supported yet.
                    ExtrapMethod = 'Clip';
                end
                if strcmp(OutputAfterFinalValue, 'Setting to zero')
                    if strcmp(Interpolate, 'on')
                        ExtrapMethod = 'Clip';
                        set_param(strcat(fromWorkSpace_list{i},'/T'),...
                            'UseLastTableValue','on');
                        % if last breakpoint is at a simulation time,
                        % add last table data with y=0 if last break point is not
                        % at a simulation time
                        additionalData = zeros(1,m);
                        additionalData(1,1) = variableMatrix(end,1);
                        variableMatrix = [variableMatrix; additionalData];
                        dt = variableMatrix(2,1) - variableMatrix(1,1);
                        variableMatrix(end-1,1) = variableMatrix(end,1) - 0.00000001*dt;
                    else
                        ExtrapMethod = 'Clip';
                        set_param(strcat(fromWorkSpace_list{i},'/T'),...
                            'UseLastTableValue','on');

                        variableMatrix(n,2:m) = 0.;
                    end

                end
                if strcmp(OutputAfterFinalValue, 'Holding final value')
                    ExtrapMethod = 'Clip';

                    set_param(strcat(fromWorkSpace_list{i},'/T'),...
                        'UseLastTableValue','on');
                end

                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'UseLastTableValue','on');

                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'ExtrapMethod',ExtrapMethod);

                % set LookupTable breakpoints and data
                table = mat2str(variableMatrix(:,2:m));
                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'BreakpointsForDimension1',mat2str(variableMatrix(:,1)));
                set_param(strcat(fromWorkSpace_list{i},'/T'),...
                    'Table',table);

            catch me
                display_msg(me.getReport(), MsgType.DEBUG, 'FromWorkSpace', '');
                status = 1;
                errors_msg{end + 1} = sprintf('FromWorkspace pre-process has failed for block %s', fromWorkSpace_list{i});
                continue;
            end
            display_msg('Done\n\n', MsgType.INFO, 'FromWorkSpace_pp', '');
        end
end





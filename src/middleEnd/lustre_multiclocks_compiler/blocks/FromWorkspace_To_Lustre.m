classdef FromWorkspace_To_Lustre < Block_To_Lustre
    %FromWorkspace_To_Lustre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            model_name = strsplit(blk.Origin_path, '/');
            model_name = model_name{1};
            SampleTime = SLXUtils.getModelCompiledSampleTime(model_name);
            
%             if strcmp(blk.OutputAfterFinalValue, 'Cyclic repetition')...
%                     ||  strcmp(blk.OutputAfterFinalValue, 'Extrapolation')
%                 display_msg(sprintf('Option %s is not supported in block %s',...
%                     blk.OutputAfterFinalValue, blk.Origin_path), ...
%                     MsgType.ERROR, 'FromWorkspace_To_Lustre', '');
%                 return;       
%             end
            
            [outputs, outputs_dt] = SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            outputDataType = blk.CompiledPortDataTypes.Outport{1};                        
            VariableName = blk.VariableName;
            [variable, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, VariableName);
            if status
                display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    VariableName, blk.Origin_path), ...
                    MsgType.ERROR, 'Constant_To_Lustr', '');
                return;
            end
            [outLusDT, zero, ~] = SLX2LusUtils.get_lustre_dt(outputDataType);
                        
            % blk parameters
            %             SampleTime = blk.SampleTime;
            %             Interpolate = blk.Interpolate;
            %             ZeroCross = blk.ZeroCross;
            %             OutputAfterFinalValue = blk.OutputAfterFinalValue;
                        
            if isnumeric(variable)
                % for matrix
                [nrow, ncol] = size(variable);
                t = variable(:,1);
                values = variable(:,2:ncol);
                dims = ncol - 1;
            elseif isstruct(variable)
                % for struct
                t = variable.time;
                nrow = numel(t);
                values = variable.signals.values;
                dims = variable.signals.dimensions;
            else
                display_msg(sprintf('Workspace variable must be numeric arrays or struct in block %s',...
                    blk.Origin_path), MsgType.ERROR, 'FromWorkspace_To_Lustre', '');
                return;
            end

%             initcode = '';
%             if strcmp(blk.OutputAfterFinalValue, 'Setting to zero')
%                 initcode = zero;
%             end
            %codes = cell(1, dims);
            blk_name = SLX2LusUtils.node_name_format(blk);
            codeAst_all = {};
            vars_all = {};            
            for i=1:dims
                
                
                %%%%%%%% old $$$$
%                 for j=nrow:-1:1
%                     a = values(j,i);
%                     if j== nrow
%                         if strcmp(blk.OutputAfterFinalValue, 'Setting to zero')
%                             code = FromWorkspace_To_Lustre.addValue(a, initcode, outLusDT);   
%                         else
%                             if strcmp(outLusDT, 'int')
%                                 code = IntExpr(a);
%                             elseif strcmp(outLusDT, 'bool')
%                                 code = BooleanExpr(a);
%                             else
%                                 code = RealExpr(a);
%                             end
%                         end
%                     else
%                         code = FromWorkspace_To_Lustre.addValue(a, code, outLusDT);                        
%                     end
%                 end
                %%%%%%%% old $$$$
                
                %%%%%%%%%% new code %%%%%%%%%%%
                time_array = t';
                data_array = values(:,i)';
                
                if numel(t) == 1      % constant case, add another point
                    t1000 = t(1) + 1000.;
                    time_array = [time_array, t1000];
                    data_array = [data_array(1), data_array(1)];                    
                end
                
                % Add data for t = 0. if none using linear extrapolation of
                % first 2 data points
                if time_array(1) > 0.
                    x = [time_array(1), time_array(2)];
                    y = [data_array(1), data_array(2)];
                    d0 = interp1(x, y, 0.,'linear','extrap');
                    time_array = [0., time_array];
                    data_array = [d0, data_array];
                end
                
                % handling blk.OutputAfterFinalValue
                t_final = time_array(end)*1.e3;
                if strcmp(blk.OutputAfterFinalValue, 'Extrapolation')
                    x = [time_array(end-1), time_array(end)];
                    y = [data_array(end-1), data_array(end)];
                    df = interp1(x, y, t_final,'linear','extrap');
                    time_array = [time_array, t_final];
                    data_array = [data_array, df];
                elseif strcmp(blk.OutputAfterFinalValue, 'Setting to zero')
                    time_array = [time_array, t_final];
                    data_array = [data_array, 0.0];
                elseif strcmp(blk.OutputAfterFinalValue, 'Holding final value')
                    time_array = [time_array, t_final];
                    data_array = [data_array, data_array(end)];
                else   % Cyclic repetition
                    
                end
                
                if numel(outputs) >= i    % TBD check with Hamza, Khanh doesn't understand this logic
                    [codeAst, vars] = ...
                        Sigbuilderblock_To_Lustre.interpTimeSeries(...
                        outputs{i},time_array, data_array, ...
                        blk_name,i);
                    
                    %codes{i} = LustreEq(outputs{i}, code);
                    %code = initcode;
                    
                    codeAst_all = [codeAst_all codeAst];
                    vars_all = [vars_all vars];
                    %%%%%%%%%% new code %%%%%%%%%%%
                end
            end
            
            obj.setCode( codeAst_all );      %%%%%%%%%% new code %%%%%%%%%%%
            obj.addVariable(outputs_dt);
            obj.addVariable(vars_all);       %%%%%%%%%% new code %%%%%%%%%%%
        end
        
        function options = getUnsupportedOptions(obj, ~, blk, varargin)
            obj.unsupported_options = {};
            VariableName = blk.VariableName;
            variable = evalin('base',VariableName);
            t = [0, 0];
            if isnumeric(variable)
                t = variable(:,1);
            elseif isstruct(variable)
                t = variable.time;
            else
                obj.addUnsupported_options(...
                    sprintf('Workspace variable must be numeric arrays or struct in block %s',...
                    blk.Origin_path));
            end
            %unsupported options
            if strcmp(blk.OutputAfterFinalValue, 'Cyclic repetition')...
                    ||  strcmp(blk.OutputAfterFinalValue, 'Extrapolation')
                obj.addUnsupported_options(...
                    sprintf('Option %s is not supported in block %s',...
                    blk.OutputAfterFinalValue, blk.Origin_path));
            end
            %Sample Time of block variable is different from Model ST
            model_name = strsplit(blk.Origin_path, '/');
            model_name = model_name{1};
            SampleTime = SLXUtils.getModelCompiledSampleTime(model_name);
            dt = t(2) - t(1);
            if dt ~= SampleTime
                obj.addUnsupported_options(...
                    sprintf('SampleTime %s in block %s is different from model SampleTime.',...
                    num2str(dt), blk.Origin_path));
                return;
            end
            options = obj.unsupported_options;
        end
    end
    methods (Static)
        function code = addValue(a, code, outLusDT)
            if strcmp(outLusDT, 'int')
                v = IntExpr(int32(a));
            elseif strcmp(outLusDT, 'bool')
                v = BooleanExpr(a);
            else
                v = RealExpr(a);
            end
            code = BinaryExpr(BinaryExpr.ARROW, ...
                    v, ...
                    UnaryExpr(UnaryExpr.PRE, code));
        end
        
    end
end


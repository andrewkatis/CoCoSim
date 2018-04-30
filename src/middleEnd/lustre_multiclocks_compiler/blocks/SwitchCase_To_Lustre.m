classdef SwitchCase_To_Lustre < Block_To_Lustre
    % SwitchCase block generates boolean conditions that will be used with the
    % Action subsystems that are linked to.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, varargin)
            %% Step 1: Get the block outputs names, If a block is called X
            % and has one outport with width 3 and datatype double,
            % then outputs = {'X_1', 'X_2', 'X_3'}
            % and outputs_dt = {'X_1:real;', 'X_2:real;', 'X_3:real;'}
            [outputs, outputs_dt] = SLX2LusUtils.getBlockOutputsNames(parent, blk);
            
            %% Step 2: add outputs_dt to the list of variables to be declared
            % in the var section of the node.
            obj.addVariable(outputs_dt);
            
            %% Step 3: construct the inputs names, if a block "X" has two inputs,
            % ("In1" and "In2")
            % "In1" is of dimension 3 and "In2" is of dimension 1.
            % Then inputs{1} = {'In1_1', 'In1_2', 'In1_3'}
            % and inputs{2} = {'In2_1'}
            
            % we initialize the inputs by empty cell.
            inputs = {};
            % take the list of the inputs width, in the previous example,
            % "In1" has a width of 3 and "In2" has a width of 1.
            % So width = [3, 1].
            widths = blk.CompiledPortWidths.Inport;
            % Go over inputs, numel(widths) is the number of inputs. In
            % this example is 2 ("In1", "In2").
            for i=1:numel(widths)
                % fill the names of the ith input.
                % inputs{1} = {'In1_1', 'In1_2', 'In1_3'}
                % and inputs{2} = {'In2_1'}
                inputs{i} = SLX2LusUtils.getBlockInputsNames(parent, blk, i);
                inports_dt{i} = SLX2LusUtils.get_lustre_dt(blk.CompiledPortDataTypes.Inport(i));
                if ~strcmp(inports_dt{i}, 'int')
                    [external_lib, conv_format] = SLX2LusUtils.dataType_conversion(inports_dt{i}, 'int');
                    if ~isempty(external_lib)
                        obj.addExternal_libraries(external_lib);
                        inputs{i} = cellfun(@(x) sprintf(conv_format,x), inputs{i}, 'un', 0);
                    end
                    inports_dt{i} = 'int';
                end
            end
            % get all conditions expressions
            IfExp = {};
            CaseConditions = eval(blk.CaseConditions);
            for i=1:numel(CaseConditions)
                if numel(CaseConditions{i}) == 1
                    IfExp{end+1} = sprintf('u1 == %d', CaseConditions{i});
                else
                    exp = {};
                    for j=1:numel(CaseConditions{i})
                        exp{j} = sprintf('u1 == %d', CaseConditions{i}(j));
                    end
                    IfExp{end+1} = MatlabUtils.strjoin(exp, ' | ');
                end
                
            end
            if strcmp(blk.ShowDefaultCase, 'on')
                IfExp{end+1} = '';
            end
            %% Step 4: start filling the definition of each output
            code = If_To_Lustre.ifElseCode(parent, blk, outputs, ...
                inputs, inports_dt, IfExp);
            obj.setCode(code);
            
        end
        
        function options = getUnsupportedOptions(obj,parent, blk, varargin)
            % add your unsuported options list here
            options = obj.unsupported_options;
            
        end
        
    end
   
    
end


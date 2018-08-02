classdef UnaryMinus_To_Lustre < Block_To_Lustre
    % UnaryMinus_To_Lustre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            %% Step 1: Get the block outputs names,
            [outputs, outputs_dt] = SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            
            %% Step 2: add outputs_dt to the list of variables to be declared
            % in the var section of the node.
            obj.addVariable(outputs_dt);
            
            %% Step 3: construct the inputs names,
            
            % we initialize the inputs by empty cell.
            inputs = {};
            
            % save the information of the outport dataType,
            outputDataType = blk.CompiledPortDataTypes.Outport{1};
            
            % fill the names of the ith input.
            % inputs{1} = {'In1_1', 'In1_2', 'In1_3'}
            inputs{1} = SLX2LusUtils.getBlockInputsNames(parent, blk, 1);
            inport_dt = blk.CompiledPortDataTypes.Inport(1);
            SaturateOnIntegerOverflow = blk.SaturateOnIntegerOverflow;
            %converts the input data type(s) to the output datatype, if
            %needed. If we have a product of double with int, the
            %output will be double, so we need to cast the int input to
            %double.
            if ~strcmp(inport_dt, outputDataType)
                % this function return if a casting is needed
                % "conv_format", a library or the name of casting node
                % will be stored in "external_lib".
                [external_lib, conv_format] = SLX2LusUtils.dataType_conversion(inport_dt, outputDataType, [], SaturateOnIntegerOverflow);
                if ~isempty(external_lib)
                    % always add the "external_lib" to the object
                    % external libraries, (so it can be declared in the
                    % overall lustre code).
                    obj.addExternal_libraries(external_lib);
                    % cast the input to the conversion format. In our
                    % example conv_format = 'int_to_real(%s)'.
                    inputs{1} = cellfun(@(x) ...
                        SLX2LusUtils.setArgInConvFormat(conv_format,x), inputs{1}, 'un', 0);
                end
            end
            
            
            %% Step 4: start filling the definition of each output
            codes = {};
            isSignedInt = true;
            if strcmp(inport_dt, 'int8')
                vmin = -128;
                vmax = 127;
            elseif strcmp(inport_dt, 'int16')
                vmin = -32768;
                vmax = 32767;
            elseif strcmp(inport_dt, 'int32')
                vmin = -2147483648;
                vmax = 2147483647;
            else
                isSignedInt = false;
            end
            if isSignedInt
                if strcmp(SaturateOnIntegerOverflow, 'off')
                    vmax = vmin;
                end
                % Go over outputs
                for j=1:numel(outputs)
                    % example of lement wise product block.
                    codes{j} = sprintf('%s = if %s = %d then %d else -%s;\n\t', ...
                        outputs{j}, inputs{1}{j}, vmin, vmax, inputs{1}{j});
                end
            else
                % Go over outputs
                for j=1:numel(outputs)
                    % example of lement wise product block.
                    codes{j} = sprintf('%s = -%s;\n\t', ...
                        outputs{j}, inputs{1}{j});
                end
            end
            
            % join the lines and set the block code.
            obj.setCode(MatlabUtils.strjoin(codes, ''));
            
        end
        
        function options = getUnsupportedOptions(obj,parent, blk, varargin)
            % add your unsuported options list here
            options = obj.unsupported_options;
            
        end
    end
    
end


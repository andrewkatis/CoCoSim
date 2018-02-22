classdef Abs_To_Lustre < Block_To_Lustre
    %Test_write a dummy class
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, varargin)
            [outputs, outputs_dt] = SLX2LusUtils.getBlockOutputsNames(blk);
            inputs = {};
            
            widths = blk.CompiledPortWidths.Inport;
            max_width = max(widths);
            outputDataType = blk.CompiledPortDataTypes.Outport(1);
            RndMeth = blk.RndMeth;
            for i=1:numel(widths)
                inputs{i} = SLX2LusUtils.getBlockInputsNames(parent, blk, i);
                if numel(inputs{i}) < max_width
                    inputs{i} = arrayfun(@(x) {inputs{i}{1}}, (1:max_width));
                end
                inport_dt = blk.CompiledPortDataTypes.Inport(i);
                %converts the input data type(s) to
                %its accumulator data type
                if ~strcmp(inport_dt, outputDataType)
                    [external_lib, conv_format] = SLX2LusUtils.dataType_conversion(inport_dt, outputDataType, RndMeth);
                    if ~isempty(external_lib)
                        obj.external_libraries = [obj.external_libraries,...
                            external_lib];
                        inputs{i} = cellfun(@(x) sprintf(conv_format,x), inputs{i}, 'un', 0);
                    end
                end
            end
            [~, zero] = SLX2LusUtils.get_lustre_dt(outputDataType);
            [external_lib, conv_format] = SLX2LusUtils.dataType_conversion(outputDataType, blk.OutDataTypeStr, RndMeth);
            if ~isempty(external_lib)
                obj.external_libraries = [obj.external_libraries,...
                    external_lib];
            end
            codes = {};
            for j=1:numel(inputs{1})
                code = sprintf('if %s >= %s then %s else -%s', inputs{1}{j}, zero, inputs{1}{j}, inputs{1}{j});
                if ~isempty(conv_format)
                    code = sprintf(conv_format, code);
                end
                codes{j} = sprintf('%s = %s;\n\t', outputs{j}, code);
            end
            
            obj.code = MatlabUtils.strjoin(codes, '');
            obj.variables = outputs_dt;
        end
        
        function getUnsupportedOptions(obj, varargin)
            % add your unsuported options list here
            obj.unsupported_options = {};
        end
    end
    
end


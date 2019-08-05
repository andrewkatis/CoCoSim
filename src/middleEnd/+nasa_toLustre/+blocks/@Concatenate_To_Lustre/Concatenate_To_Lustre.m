classdef Concatenate_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    % Concatenate_To_Lustre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            
            [outputs, outputs_dt] = ...
               nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            [inputs,widths] = ...
                nasa_toLustre.blocks.Concatenate_To_Lustre.getBlockInputsNames_convInType2AccType(obj, parent, blk);
            [blkParams,in_matrix_dimension] = nasa_toLustre.blocks.Concatenate_To_Lustre.readBlkParams(blk);
            nb_inputs = numel(widths);
            if blkParams.isVector
                [codes] = nasa_toLustre.blocks.Concatenate_To_Lustre.concatenateVector(nb_inputs, inputs, outputs);
            else
                [ConcatenateDimension, ~, status] = ...
                    nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(parent, blk, blk.ConcatenateDimension);
                if status
                    display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                        blk.ConcatenateDimension, HtmlItem.addOpenCmd(blk.Origin_path)), ...
                        MsgType.ERROR, 'Concatenate_To_Lustre', '');
                    return;
                end
                
                codes = cell(1, numel(outputs));
                inputs_reshaped = {};
                for i=1:length(in_matrix_dimension)
                    inputs_reshaped{i} = reshape(inputs{i}, ...
                        in_matrix_dimension{i}.dims);
                end
                Y = cat(ConcatenateDimension,inputs_reshaped{:});
                Y_inlined = reshape(Y, [1, numel(Y)]);
                for i=1:numel(outputs)
                    codes{i} = nasa_toLustre.lustreAst.LustreEq(outputs{i},...
                        Y_inlined{i});
                end

            end
            
            obj.addCode( codes );
            obj.addVariable(outputs_dt);
        end
        
        function options = getUnsupportedOptions(obj, parent, blk, varargin)
            
            [ConcatenateDimension, ~, status] = ...
                nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(parent, blk, blk.ConcatenateDimension);
            if status
                obj.addUnsupported_options(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.ConcatenateDimension, HtmlItem.addOpenCmd(blk.Origin_path)));
            end

            if ConcatenateDimension > 2
                obj.addUnsupported_options(sprintf('ConcatenateDimension > 2 in block %s',...
                        HtmlItem.addOpenCmd(blk.Origin_path)));
            end
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
    methods(Static)
        
        [blkParams,in_matrix_dimension] = readBlkParams(blk)
        
        [codes] = concatenateDimension1(inputs, outputs,in_matrix_dimension)
        
        [inputs,widths] = getBlockInputsNames_convInType2AccType(obj, parent, blk)
        
        [codes] = concatenateDimension2(inputs, outputs,in_matrix_dimension)
        
        [codes] = concatenateVector(nb_inputs, inputs, outputs)
        
    end
    
end


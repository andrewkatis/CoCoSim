%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
% Notices:
%
% Copyright @ 2020 United States Government as represented by the 
% Administrator of the National Aeronautics and Space Administration.  All 
% Rights Reserved.
%
% Disclaimers
%
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY 
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING,
% BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM 
% TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS 
% FOR A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
% THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT 
% DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS 
% AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY 
% GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING 
% DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING 
% FROM USE OF THE SUBJECT SOFTWARE.  FURTHER, GOVERNMENT AGENCY DISCLAIMS 
% ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF PRESENT 
% IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS."
%
% Waiver and Indemnity:  RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS 
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, 
% AS WELL AS ANY PRIOR RECIPIENT.  IF RECIPIENT'S USE OF THE SUBJECT 
% SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES, EXPENSES OR 
% LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM PRODUCTS BASED 
% ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT SOFTWARE, RECIPIENT 
% SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED STATES GOVERNMENT, ITS 
% CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT, TO THE 
% EXTENT PERMITTED BY LAW.  RECIPIENT'S SOLE REMEDY FOR ANY SUCH MATTER 
% SHALL BE THE IMMEDIATE, UNILATERAL TERMINATION OF THIS AGREEMENT.
% 
% Notice: The accuracy and quality of the results of running CoCoSim 
% directly corresponds to the quality and accuracy of the model and the 
% requirements given as inputs to CoCoSim. If the models and requirements 
% are incorrectly captured or incorrectly input into CoCoSim, the results 
% cannot be relied upon to generate or error check software being developed. 
% Simply stated, the results of CoCoSim are only as good as
% the inputs given to CoCoSim.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef BusAssignment_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    %BusAssignment_To_Lustre

    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, ~, ~, main_sampleTime, varargin)
            
            [outputs, outputs_dt] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace, main_sampleTime);
            obj.addVariable(outputs_dt);
            widths = blk.CompiledPortWidths.Inport;
            inputs = cell(1, numel(widths));
            for i=1:numel(widths)
                inputs{i} =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk, i);
            end
            try
                [SignalsInputsMap, AssignedSignals] = obj.getSignalMap(blk, inputs);
            catch me
                if strcmp(me.identifier, 'COCOSIM:BusSelector_To_Lustre') ...
                        || strcmp(me.identifier, 'COCOSIM:BusAssignment_To_Lustre')
                    display_msg(me.message, MsgType.ERROR, 'BusAssignment_To_Lustre', '');
                    return;
                end
            end
            modifiedInputs = inputs{1};
            for i=1:numel(AssignedSignals)
                if isKey(SignalsInputsMap, AssignedSignals{i})
                    inputs_i = SignalsInputsMap(AssignedSignals{i});
                else
                    display_msg(sprintf('Block %s with type %s is not supported.',...
                        HtmlItem.addOpenCmd(blk.Origin_path), AssignedSignals{i}),...
                        MsgType.ERROR, 'BusAssignment_To_Lustre', '');
                    continue;
                end
                for j=1:numel(inputs_i)
                    idx = nasa_toLustre.blocks.BusAssignment_To_Lustre.findIdx(modifiedInputs, inputs_i{j});
                    modifiedInputs{idx} = ...
                        inputs{i+1}{j};
                end
            end
            codes = cell(1, numel(outputs));
            for i=1:numel(outputs)
                codes{i} = nasa_toLustre.lustreAst.LustreEq(outputs{i}, modifiedInputs{i});
            end
            obj.addCode( codes );
        end
        %%
        function options = getUnsupportedOptions(obj, parent, blk, varargin)
            
            widths = blk.CompiledPortWidths.Inport;
            inputs = cell(1, numel(widths));
            for i=1:numel(widths)
                inputs{i} =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk, i);
            end
            try
                [SignalsInputsMap, AssignedSignals] = obj.getSignalMap(blk, inputs);
                for i=1:numel(AssignedSignals)
                    if ~isKey(SignalsInputsMap, AssignedSignals{i})
                        obj.addUnsupported_options(sprintf('Block %s with type %s is not supported.',...
                            HtmlItem.addOpenCmd(blk.Origin_path), AssignedSignals{i}));
                    end
                end
            catch me
                if strcmp(me.identifier, 'COCOSIM:BusSelector_To_Lustre') ...
                        || strcmp(me.identifier, 'COCOSIM:BusAssignment_To_Lustre')
                    obj.addUnsupported_options(me.message);
                end
            end
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
        %%
        [SignalsInputsMap, AssignedSignals] = getSignalMap(obj, blk, inputs)

    end
    
    methods(Static)
        idx = findIdx(VarIds, var)
    end
    
end


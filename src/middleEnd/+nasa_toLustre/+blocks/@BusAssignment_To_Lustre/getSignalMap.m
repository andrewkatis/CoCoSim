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
function [SignalsInputsMap, AssignedSignals] = getSignalMap(obj, blk, inputs)

    
    % everything is inlined
    InportDimensions = blk.CompiledPortDimensions.Inport;
    InputSignals = blk.InputSignals;
    AssignedSignals = regexp(blk.AssignedSignals, ',', 'split');
    inputSignalsInlined = nasa_toLustre.blocks.BusSelector_To_Lustre.inlineInputSignals(InputSignals);
    if InportDimensions(1) == -2
        % case of virtual bus
        inport_cell_dimension =...
            nasa_toLustre.blocks.Assignment_To_Lustre.getInputMatrixDimensions(InportDimensions);
        if numel(inport_cell_dimension) > numel(inputSignalsInlined)
            inport_cell_dimension = inport_cell_dimension(1:numel(inputSignalsInlined));
        end
    else
        InportDT = blk.CompiledPortDataTypes.Inport{1};
        try
            isBus = evalin('base', sprintf('isa(%s, ''Simulink.Bus'')',char(InportDT)));
        catch
            isBus = false;
        end
        if isBus
            % case of bus object
            inport_cell_dimension =nasa_toLustre.utils.SLX2LusUtils.getDimensionsFromBusObject(InportDT);
        else
            ME = MException('COCOSIM:BusAssignment_To_Lustre', ...
                'Block %s with type %s is not supported.', ...
                HtmlItem.addOpenCmd(blk.Origin_path), InportDT);
            throw(ME);
        end
    end
    SignalsInputsMap = nasa_toLustre.blocks.BusSelector_To_Lustre.signalInputsUsingDimensions(...
        blk, inport_cell_dimension, inputSignalsInlined, inputs{1});
end



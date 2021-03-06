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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef LustrecUtils < handle
    %LUSTRECUTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static = true)
        %%
        t = adapt_lustre_text(t, lusBackend, output_dir)
        
        new_mcdc_file = adapt_lustre_file(mcdc_file, dest)
        
        %%
        report = parseLustrecErrorMessage(message, msg_type)
        %%
        [lusi_path, status, lusi_out] = generate_lusi(lus_file_path, LUSTREC )
        %%
        [emf_path, status] = ...
                generate_emf(lus_file_path, output_dir, ...
                LUSTREC,...
                LUSTREC_OPTS,...
                LUCTREC_INCLUDE_DIR)       
        %% MCDC generation
        [mcdc_file] = generate_MCDCLustreFile(lus_full_path, output_dir)
        
        %% Lustrev seal generation
        [seal_file, status] = generateLustrevSealFile(lus_full_path, output_dir, main_node, LUSTREV, LUCTREC_INCLUDE_DIR)
        %% compile_lustre_to_Cbinary
        err = compile_lustre_to_Cbinary(lus_file_path, ...
            node_name, ...
            output_dir, ...
            LUSTREC,...
            LUSTREC_OPTS, ...
            LUCTREC_INCLUDE_DIR)
        %% node inputs outputs
        [node_struct,...
            status] = extract_node_struct(lus_file_path,...
            node_name,...
            LUSTREC,...
            LUCTREC_INCLUDE_DIR)
        
        [node_struct,...
            status] = extract_node_struct_using_lusi(lus_file_path,...
            node_name,...
            LUSTREC)
        [node_struct,...
            status] = extract_node_struct_using_lusFile(lus_file_path,...
            node_name)
        
        [main_node_struct, ...
            status] = extract_node_struct_using_emf(...
            lus_file_path,...
            main_node_name,...
            LUSTREC, ...
            LUCTREC_INCLUDE_DIR)
        %%
        verif_node = construct_verif_node(...
            node_struct, node_name, new_node_name)
        %% construct_EMF_verif_model
        status = check_DType_and_Dimensions(slx_file_name)
        
        inport_idx = add_demux(new_model_name, inport_idx, inport_name, dim,...
            demux_outHandle, demux_inHandle)
        
        idx = add_mux(new_model_name, outport_idx, i, muxID, dim,...
            mux_inHandle, mux_outHandle, dim_3, colon )
        
        [status, new_name_path] = construct_EMF_verif_model(slx_file_name,...
            lus_file_path, node_name, output_dir)
        %% construct EMF  model
        [status, new_name_path, emf_path, xml_trace] = construct_EMF_model(...
            lus_file_path, node_name, output_dir, organize_blocks)
        %% verification file
        verif_lus_path = create_mutant_verif_file(lus_file_path, mutant_lus_fpath, ...
            node_struct, node_name, new_node_name, model_checker)
        
        %% compositional verification file between EMF and cocosim
        [verif_lus_path, nodes_list] = create_emf_verif_file(...
            lus_file_path,...
            coco_lus_fpath,...
            emf_path, ...
            EMF_trace_xml, ...
            toLustre_Trace_xml)
        
        contract = construct_contact(node_struct, node_name)
        
        %% run Zustre or kind2 on verification file
        
        [answer, IN_struct, time_max] = run_verif(...
            verif_lus_path,...
            inports, ...
            output_dir,...
            node_name,...
            Backend)
        
        [answer, CEX_XML] = extract_answer(...
            solver_output,solver, ...
            file_name, ...
            node_name, ...
            output_dir)
        
        [ds, time_max] = cexTostruct(...
            cex_xml, ...
            node_name,...
            inports)
        
        [values, time_step] = extract_values( stream, dt)
        
        %% transform input struct to lustre format (inlining values)
        [lustre_input_values, status] = getLustreInputValuesFormat(...
            input_dataSet, time, node_struct)
        
        number_of_inputs = getNumberOfInputsInlinedFromDataSet(ds, nb_steps)
        
        signal_values = getSignalValuesInlinedUsingTime(ds, t)
        
        width = getSignalWidth(ds)
        
        %% print input_values for lustre binary
        status = printLustreInputValues(...
            lustre_input_values,...
            output_dir, ...
            file_name)
        
        %% extract lustre outputs from lustre binary
        status = extract_lustre_outputs(...
            lus_file_name,...
            binary_dir, ...
            node_name,...
            input_file_name,...
            output_file_name)
        
        %% compare Simulin outputs and Lustre outputs
        [valid, cex_msg, diff_name, diff] = ...
            compare_Simu_outputs_with_Lus_outputs(...
            input_dataset, ...
            yout,...
            outputs_array, ...
            eps, ...
            time)
        
        [valid, cex_msg, diff_name, diff_value, sim_failed] = ...
            compare_slx_out_with_lusORslx_out(...
            input_dataSet, ...
            yout1,...
            yout2, ...
            lus_outs, ...
            eps, ...
            time)
        
        %%
        [y_inlined, width, status] = inline_array(y_struct, time_step)
        
        %% Show CEX
        show_CEX(cex_msg, cex_file_path )
        
        %% run comparaison
        time = getTimefromDataset(ds)
        
        [valid,...
            lustrec_failed, ...
            lustrec_binary_failed,...
            sim_failed, ...
            done, ...
            cex_file_path] = ...
            run_comparaison(slx_file_name, ...
            lus_file_path,...
            node_name, ...
            input_dataSet,...
            output_dir,...
            input_file_name, ...
            output_file_name, ...
            eps, ...
            show_models)
        
    end
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
       
function idx = add_mux(new_model_name, outport_idx, i, muxID, dim,...
        mux_inHandle, mux_outHandle, dim_3, colon )
    p = get_param(mux_inHandle.Outport(outport_idx+1), 'Position');
    x = p(1) + 50;
    y = p(2);
    mux_path = strcat(new_model_name,'/Mux',muxID);
    mux_pos(1) = (x - 10);
    mux_pos(2) = (y - 10);
    mux_pos(3) = (x + 10);
    mux_pos(4) = (y + 50 * dim);
    h = add_block('simulink/Signal Routing/Mux',...
        mux_path,...
        'MakeNameUnique', 'on', ...
        'Inputs', num2str(dim),...
        'Position',mux_pos);
    mux_Porthandl = get_param(h, 'PortHandles');
    add_line(new_model_name,...
        mux_Porthandl.Outport(1),...
        mux_outHandle.Inport(i), ...
        'autorouting', 'on');
    for j=1:dim
        idx = outport_idx + dim_3*(j-1) + colon;
        add_line(new_model_name,...
            mux_inHandle.Outport(idx), ...
            mux_Porthandl.Inport(j),...
            'autorouting', 'on');

    end
end

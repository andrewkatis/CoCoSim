%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

function [x2, y2] = process_arrow(node_block_path, blk_exprs, var, node_name, x2, y2)
    if y2 < 30000; y2 = y2 + 150; else, x2 = x2 + 500; y2 = 100; end
    ID = BUtils.adapt_block_name(var{1});
    lhs_name = BUtils.adapt_block_name(blk_exprs.(var{1}).lhs, node_name);
    lhs_path = strcat(node_block_path,'/',ID, '_lhs');
    init_path =  strcat(node_block_path,'/',ID,'_init');
    delay_path = strcat(node_block_path,'/Arrow_',ID);

    add_block('simulink/Commonly Used Blocks/Constant',...
        init_path,...
        'Value','0',...
        'OutDataTypeStr','boolean',...
        'Position',[x2 y2 (x2+50) (y2+50)]);
    add_block('simulink/Discrete/Delay',...
        delay_path,...
        'InitialCondition','1',...
        'DelayLength','1',...
        'Position',[(x2+100) y2 (x2+150) (y2+50)]);
    add_block('simulink/Signal Routing/Goto',...
        lhs_path,...
        'GotoTag',lhs_name,...
        'TagVisibility', 'local', ...
        'Position',[(x2+200) y2 (x2+250) (y2+50)]);

    SrcBlkH = get_param(init_path,'PortHandles');
    DstBlkH = get_param(delay_path, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');

    SrcBlkH = get_param(delay_path,'PortHandles');
    DstBlkH = get_param(lhs_path, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');

end

classdef BitClear_Test < Block_Test
    %BitClear_Test generates test automatically.
    
    properties(Constant)
        fileNamePrefix = 'BitClear_TestGen';
        blkLibPath = 'simulink/Logic and Bit Operations/Bit Clear';
    end
    
    properties
        % properties that will participate in permutations
        inputDataType = {'int8','uint8','int16','uint16'};
        iBit = {'0','[1 2 3]', '[0 2; 3 4]'};
    end
    
    properties
        % other properties
        
    end
    
    methods
        function status = generateTests(obj, outputDir, deleteIfExists)
            if ~exist('deleteIfExists', 'var')
                deleteIfExists = true;
            end
            status = 0;
            params = obj.getParams();
            nb_tests = length(params);
            condExecSSPeriod = floor(nb_tests/length(Block_Test.condExecSS));
            if condExecSSPeriod <= 1
                condExecSSPeriod = floor(nb_tests/3);
            end
            for i=1 : nb_tests
                try
                    s = params{i};
                    %% creat new model
                    mdl_name = sprintf('%s%d', obj.fileNamePrefix, i);
                    addCondExecSS = (mod(i, condExecSSPeriod) == 0);
                    condExecSSIdx = int32(i/condExecSSPeriod);
                    [blkPath, mdl_path, skip] = Block_Test.create_new_model(...
                        mdl_name, outputDir, deleteIfExists, addCondExecSS, ...
                        condExecSSIdx);
                    if skip
                        continue;
                    end
                    
                    %% remove parametres that does not belong to block params
                    inpDataType = s.inputDataType;
                    s = rmfield(s,'inputDataType');
                    inputDims  = s.inputDims;
                    s = rmfield(s,'inputDims');
                    %% add the block
                    
                    Block_Test.add_and_connect_block(obj.blkLibPath, blkPath, s);
                    
                    %% go over inports
                    try
                        blk_parent = get_param(blkPath, 'Parent');
                    catch
                        blk_parent = fileparts(blkPath);
                    end
                    inport_list = find_system(blk_parent, ...
                        'SearchDepth',1, 'BlockType','Inport');
                    
                    % rotate over input data type
                    set_param(inport_list{1}, ...
                        'OutDataTypeStr',inpDataType);
                    
                    set_param(inport_list{1}, ...
                        'PortDimensions', inputDims);
                    
                    failed = Block_Test.setConfigAndSave(mdl_name, mdl_path);
                    if failed, display(s), end
                    
                    
                catch me
                    display(s);
                    display_msg(['Model failed: ' mdl_name], ...
                        MsgType.DEBUG, 'generateTests', '');
                    display_msg(me.getReport(), MsgType.ERROR, 'generateTests', '');
                    bdclose(mdl_name)
                end
            end
        end
        
        
        
        function params = getParams(obj)
            params = {};
            for pInType = 1 : numel(obj.inputDataType)
                % rotate iBit
                piBit = mod(pInType, ...
                    length(obj.iBit)) + 1;
                s = struct();
                s.iBit = obj.iBit{piBit};
                s.inputDataType = obj.inputDataType{pInType};
                s.inputDims = '1';
                params{end+1} = s;
                if piBit == 1   
                    s.inputDims = '[1 3]';
                    params{end+1} = s;
                    s.inputDims = '[2 2]';
                    params{end+1} = s;
                elseif piBit == 2
                    s.inputDims = '[1 3]';
                    params{end+1} = s;
                elseif piBit == 3
                    s.inputDims = '[2 2]';
                    params{end+1} = s;
                end
                
            end
            
        end
        
    end
end


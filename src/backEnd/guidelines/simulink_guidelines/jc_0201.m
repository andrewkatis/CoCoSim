function [results, passed, priority] = jc_0201(model)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Khanh Trinh <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ORION GN&C MATLAB/Simulink Standards
    % jc_0201: Usable characters in subsystem names
    
    priority = 2;
    results = {};
    passed = 1;
    totalFail = 0;

    item_titles = {...
        'should not start with a number',...
        'should not have blank spaces',...
        'carriage returns are not allowed',...
        'Allowed Characters are [a-zA-Z_0-9]',...
        'cannot have more than one consecutive underscore',...
        'cannot start with an underscore',...
        'cannot end with an underscore'...
        };
    
    regexp_str = {...
        '^[\d_]',...
        '\s',...
        '\n',...
        'custom',...    % i=4
        '__',...
        '^_',...
        '_$'...
        };    
        
    subtitles = cell(length(item_titles)+1, 1);
    for i=1:length(item_titles)
        item_title = item_titles{i};
        if i==4
            fsList = GuidelinesUtils.allowedChars(model,{});           
        else
            fsList = find_system(model,'Regexp', 'on',...
                'blocktype','SubSystem', 'Name',regexp_str{i});
        end
        [subtitles{i+1}, numFail] = ...
            GuidelinesUtils.process_find_system_results(fsList,item_title,...
            false);
        totalFail = totalFail + numFail;
    end        
    
    if totalFail > 0
        passed = 0;
        color = 'red';
    else
        color = 'green';
    end
        
    %the main guideline
    title = 'jc_0201: Usable characters in subsystem names';
    description_text = ...
        'The names of all Subsystem blocks should conform to the following constraints:';
    description = HtmlItem(description_text, {}, 'black', 'black');     
    subtitles{1} = description;
    results{end+1} = HtmlItem(title, subtitles, color, color);
    
end


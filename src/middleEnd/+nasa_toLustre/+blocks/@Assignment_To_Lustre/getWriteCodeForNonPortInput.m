function [codes] = getWriteCodeForNonPortInput(~, in_matrix_dimension,inputs,outputs,numOutDims,U_expanded_dims,ind)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %L = nasa_toLustre.ToLustreImport.L;
    %import(L{:})
    %% function get code for noPortInput
    
    % initialization
    if numOutDims == 1              % for 1D
        U_to_Y0 = ind{1};
    else
        % support max dimensions = 7
        sub2ind_string = 'U_to_Y0 = sub2ind(in_matrix_dimension{1}.dims';
        dString = {'[ ', '[ ', '[ ', '[ ', '[ ', '[ ', '[ '};
        
        for i=1:numel(inputs{2})    % looping over U elements
            [d1, d2, d3, d4, d5, d6, d7 ] = ind2sub(U_expanded_dims.dims,i);
            d = [d1, d2, d3, d4, d5, d6, d7 ];
            
            for j=1:numel(in_matrix_dimension{1}.dims)
                y0d(j) = ind{j}(d(j));
                if i==1
                    dString{j}  = sprintf('%s%d', dString{j}, y0d(j));
                else
                    dString{j}  = sprintf('%s, %d', dString{j}, y0d(j));
                end
            end
        end
        
        for j=1:numel(in_matrix_dimension{1}.dims)
            sub2ind_string = sprintf('%s, %s]',sub2ind_string,dString{j});
        end
        sub2ind_string = sprintf('%s);',sub2ind_string);
        eval(sub2ind_string);
    end
    
    % U_to_Y0 should be defined at this point
    codes = cell(1, numel(outputs));
    for i=1:numel(outputs)
        if find(U_to_Y0==i)
            Uindex = find(U_to_Y0==i);
            codes{i} = nasa_toLustre.lustreAst.LustreEq(outputs{i}, inputs{2}{Uindex});
        else
            codes{i} = nasa_toLustre.lustreAst.LustreEq(outputs{i}, inputs{1}{i});
        end
    end
end

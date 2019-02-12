%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Khanh Tringh <khanh.v.trinh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function body = get_Det_Adjugate_Code(n,det,a,adj)
    import nasa_toLustre.lustreAst.*
    body = {};
    body{1} = AssertExpr(BinaryExpr(BinaryExpr.NEQ, ...
        det, RealExpr('0.0')));
    if n == 2
        % det
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{2,2});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{2,1});
        body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.MINUS,term1,term2));
        % adjugate & inverse
        body{end+1} = LustreEq(adj{1,1},a{2,2});
        body{end+1} = LustreEq(adj{1,2},UnaryExpr(UnaryExpr.NEG,a{1,2}));
        body{end+1} = LustreEq(adj{2,1},UnaryExpr(UnaryExpr.NEG,a{2,1}));
        body{end+1} = LustreEq(adj{2,2},a{1,1});
    elseif n == 3
        % define det
        term1 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},adj{1,1});
        term2 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},adj{2,1});
        term4 = BinaryExpr(BinaryExpr.PLUS,term1,term2);
        term3 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},adj{3,1});
        body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.PLUS,term4,term3));
        % define adjugate
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,2},a{3,3});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{3,2});
        body{end+1} = LustreEq(adj{1,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{3,1});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{3,3});
        body{end+1} = LustreEq(adj{2,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{3,2});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,1},a{2,2});
        body{end+1} = LustreEq(adj{3,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{3,2});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,3},a{1,2});
        body{end+1} = LustreEq(adj{1,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{3,3});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{3,1});
        body{end+1} = LustreEq(adj{2,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{3,1});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,2},a{1,1});
        body{end+1} = LustreEq(adj{3,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{2,3});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,2},a{1,3});
        body{end+1} = LustreEq(adj{1,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{2,1});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{1,1});
        body{end+1} = LustreEq(adj{2,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
        term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{2,2});
        term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{1,2});
        body{end+1} = LustreEq(adj{3,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
    elseif n  == 4
        % define det
        term1 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},adj{1,1});
        term2 =  BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},adj{1,2});
        term3 =  BinaryExpr(BinaryExpr.MULTIPLY,a{3,1},adj{1,3});
        term4 =  BinaryExpr(BinaryExpr.MULTIPLY,a{4,1},adj{1,4});
        term5 =  BinaryExpr(BinaryExpr.PLUS,term1,term2);
        term6 =  BinaryExpr(BinaryExpr.PLUS,term3,term4);
        body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.PLUS,term5,term6));
        % define adjugate
        %   adj11
        list{1} = {a{2,2},a{3,3},a{4,4}};
        list{2} = {a{2,3},a{3,4},a{4,2}};
        list{3} = {a{2,4},a{3,2},a{4,3}};
        list{4} = {a{2,4},a{3,3},a{4,2}};
        list{5} = {a{2,3},a{3,2},a{4,4}};
        list{6} = {a{2,2},a{3,4},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{1,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %   adj12
        list{1} = {a{1,4},a{3,3},a{4,2}};
        list{2} = {a{1,3},a{3,2},a{4,4}};
        list{3} = {a{1,2},a{3,4},a{4,3}};
        list{4} = {a{1,2},a{3,3},a{4,4}};
        list{5} = {a{1,3},a{3,4},a{4,2}};
        list{6} = {a{1,4},a{3,2},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{1,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %   adj13
        list{1} = {a{1,2},a{2,3},a{4,4}};
        list{2} = {a{1,3},a{2,4},a{4,2}};
        list{3} = {a{1,4},a{2,2},a{4,3}};
        list{4} = {a{1,4},a{2,3},a{4,2}};
        list{5} = {a{1,3},a{2,2},a{4,4}};
        list{6} = {a{1,2},a{2,4},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{1,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %     adj14
        list{1} = {a{1,4},a{2,3},a{3,2}};
        list{2} = {a{1,3},a{2,2},a{3,4}};
        list{3} = {a{1,2},a{2,4},a{3,3}};
        list{4} = {a{1,2},a{2,3},a{3,4}};
        list{5} = {a{1,3},a{2,4},a{3,2}};
        list{6} = {a{1,4},a{2,2},a{3,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{1,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj21
        list{1} = {a{2,4},a{3,3},a{4,1}};
        list{2} = {a{2,3},a{3,1},a{4,4}};
        list{3} = {a{2,1},a{3,4},a{4,3}};
        list{4} = {a{2,1},a{3,3},a{4,4}};
        list{5} = {a{2,3},a{3,4},a{4,1}};
        list{6} = {a{2,4},a{3,1},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{2,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj22
        list{1} = {a{1,1},a{3,3},a{4,4}};
        list{2} = {a{1,3},a{3,4},a{4,1}};
        list{3} = {a{1,4},a{3,1},a{4,3}};
        list{4} = {a{1,4},a{3,3},a{4,1}};
        list{5} = {a{1,3},a{3,1},a{4,4}};
        list{6} = {a{1,1},a{3,4},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{2,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj23
        list{1} = {a{1,4},a{2,3},a{4,1}};
        list{2} = {a{1,3},a{2,1},a{4,4}};
        list{3} = {a{1,1},a{2,4},a{4,3}};
        list{4} = {a{1,1},a{2,3},a{4,4}};
        list{5} = {a{1,3},a{2,4},a{4,1}};
        list{6} = {a{1,4},a{2,1},a{4,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{2,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj24
        list{1} = {a{1,1},a{2,3},a{3,4}};
        list{2} = {a{1,3},a{2,4},a{3,1}};
        list{3} = {a{1,4},a{2,1},a{3,3}};
        list{4} = {a{1,4},a{2,3},a{3,1}};
        list{5} = {a{1,3},a{2,1},a{3,4}};
        list{6} = {a{1,1},a{2,4},a{3,3}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{2,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj31
        list{1} = {a{2,1},a{3,2},a{4,4}};
        list{2} = {a{2,2},a{3,4},a{4,1}};
        list{3} = {a{2,4},a{3,1},a{4,2}};
        list{4} = {a{2,4},a{3,2},a{4,1}};
        list{5} = {a{2,2},a{3,1},a{4,4}};
        list{6} = {a{2,1},a{3,4},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{3,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj32
        list{1} = {a{1,4},a{3,2},a{4,1}};
        list{2} = {a{1,2},a{3,1},a{4,4}};
        list{3} = {a{1,1},a{3,4},a{4,2}};
        list{4} = {a{1,1},a{3,2},a{4,4}};
        list{5} = {a{1,2},a{3,4},a{4,1}};
        list{6} = {a{1,4},a{3,1},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{3,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj33
        list{1} = {a{1,1},a{2,2},a{4,4}};
        list{2} = {a{1,2},a{2,4},a{4,1}};
        list{3} = {a{1,4},a{2,1},a{4,2}};
        list{4} = {a{1,4},a{2,2},a{4,1}};
        list{5} = {a{1,2},a{2,1},a{4,4}};
        list{6} = {a{1,1},a{2,4},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{3,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %     adj34
        list{1} = {a{1,4},a{2,2},a{3,1}};
        list{2} = {a{1,2},a{2,1},a{3,4}};
        list{3} = {a{1,1},a{2,4},a{3,2}};
        list{4} = {a{1,1},a{2,2},a{3,4}};
        list{5} = {a{1,2},a{2,4},a{3,1}};
        list{6} = {a{1,4},a{2,1},a{3,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{3,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %   adj41
        list{1} = {a{2,3},a{3,2},a{4,1}};
        list{2} = {a{2,2},a{3,1},a{4,3}};
        list{3} = {a{2,1},a{3,3},a{4,2}};
        list{4} = {a{2,1},a{3,2},a{4,3}};
        list{5} = {a{2,2},a{3,3},a{4,1}};
        list{6} = {a{2,3},a{3,1},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{4,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj42
        list{1} = {a{1,1},a{3,2},a{4,3}};
        list{2} = {a{1,2},a{3,3},a{4,1}};
        list{3} = {a{1,3},a{3,1},a{4,2}};
        list{4} = {a{1,3},a{3,2},a{4,1}};
        list{5} = {a{1,2},a{3,1},a{4,3}};
        list{6} = {a{1,1},a{3,3},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{4,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        %    adj43
        list{1} = {a{1,3},a{2,2},a{4,1}};
        list{2} = {a{1,2},a{2,1},a{4,3}};
        list{3} = {a{1,1},a{2,3},a{4,2}};
        list{4} = {a{1,1},a{2,2},a{4,3}};
        list{5} = {a{1,2},a{2,3},a{4,1}};
        list{6} = {a{1,3},a{2,1},a{4,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{4,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
        % adj44
        list{1} = {a{1,1},a{2,2},a{3,3}};
        list{2} = {a{1,2},a{2,3},a{3,1}};
        list{3} = {a{1,3},a{2,1},a{3,2}};
        list{4} = {a{1,3},a{2,2},a{3,1}};
        list{5} = {a{1,2},a{2,1},a{3,3}};
        list{6} = {a{1,1},a{2,3},a{3,2}};
        terms = cell(1,6);
        for i=1:6
            terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
        end        
        termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
        termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
        body{end+1} = LustreEq(adj{4,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
    else
        display_msg(...
            sprintf('Option Matrix(*) with divid is not supported in block LustMathLib'), ...
            MsgType.ERROR, 'LustMathLib', '');
        return;
    end
end
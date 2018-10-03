classdef LustreEq < LustreAst
    %LustreEq
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        lhs;
        rhs;
    end
    
    methods 
        function obj = LustreEq(lhs, rhs)
            if ischar(rhs)
                obj.rhs = VarIdExpr(rhs);
            else
                obj.rhs = rhs;
            end
            obj.lhs = lhs;
        end
        
        function new_obj = deepCopy(obj)
            if iscell(obj.lhs)
                new_lhs = cellfun(@(x) x.deepCopy(), obj.lhs, 'UniformOutput', 0);
            else
                new_lhs = obj.lhs.deepCopy();
            end
            if iscell(obj.rhs)
                new_rhs = cellfun(@(x) x.deepCopy(), obj.rhs, 'UniformOutput', 0);
            else
                new_rhs = obj.rhs.deepCopy();
            end
            new_obj = LustreEq(new_lhs, new_rhs);
        end
        %% This functions are used for ForIterator block
        function [new_obj, varIds] = changePre2Var(obj)
            varIds = {};
            if iscell(obj.lhs)
                [new_lhs, VarIdlhs] = obj.lhs{1}.changePre2Var();
            else
                [new_lhs, VarIdlhs] = obj.lhs.changePre2Var();
            end
            varIds = [varIds, VarIdlhs];
            if iscell(obj.rhs)
                [new_rhs, VarIdrhs] = obj.rhs{1}.changePre2Var();
            else
                [new_rhs, VarIdrhs] = obj.rhs.changePre2Var();
            end
            varIds = [varIds, VarIdrhs];
            new_obj = LustreEq(new_lhs, new_rhs);
        end
        
        function new_obj = changeArrowExp(obj, cond)
            if iscell(obj.rhs)
                new_rhs = cellfun(@(x) x.changeArrowExp(cond), obj.rhs, 'UniformOutput', 0);
            else
                new_rhs = obj.rhs.changeArrowExp(cond);
            end
            new_obj = LustreEq(obj.lhs, new_rhs);
        end
        
        %%
        function code = print(obj, backend)
            %TODO: check if LUSTREC syntax is OK for the other backends.
            code = obj.print_lustrec(backend);
        end
        
        
        function code = print_lustrec(obj, backend)
            if iscell(obj.lhs)
                lhs_cell = cellfun(@(x) x.print(backend), obj.lhs, 'UniformOutput', 0);
                lhs_str = sprintf('(%s)', ...
                    MatlabUtils.strjoin(lhs_cell, ', '));
            else
                lhs_str = obj.lhs.print(backend);
            end
            if iscell(obj.rhs)
                rhs_str = obj.rhs{1}.print(backend);
            else
                rhs_str = obj.rhs.print(backend);
            end
            
            code = sprintf('%s = %s;', lhs_str, rhs_str);
        end
        
        function code = print_kind2(obj)
            code = obj.print_lustrec(BackendType.KIND2);
        end
        function code = print_zustre(obj)
            code = obj.print_lustrec(BackendType.ZUSTRE);
        end
        function code = print_jkind(obj)
            code = obj.print_lustrec(BackendType.JKIND);
        end
        function code = print_prelude(obj)
            code = obj.print_lustrec(BackendType.PRELUDE);
        end
    end

end


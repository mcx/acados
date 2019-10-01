%
% Copyright 2019 Gianluca Frison, Dimitris Kouzoupis, Robin Verschueren,
% Andrea Zanelli, Niels van Duijkeren, Jonathan Frey, Tommaso Sartor,
% Branimir Novoselnik, Rien Quirynen, Rezart Qelibari, Dang Doan,
% Jonas Koenemann, Yutao Chen, Tobias Schöls, Jonas Schlagenhauf, Moritz Diehl
%
% This file is part of acados.
%
% The 2-Clause BSD License
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.;
%

classdef acados_ocp < handle

    properties
        C_ocp
        C_ocp_ext_fun
        model_struct
        opts_struct
    end % properties



    methods


        function obj = acados_ocp(model, opts)
            obj.model_struct = model.model_struct;
            obj.opts_struct = opts.opts_struct;

            [~,~] = mkdir(obj.opts_struct.output_dir);
            addpath(obj.opts_struct.output_dir);

            % detect GNSF structure
            if (strcmp(obj.opts_struct.sim_method, 'irk_gnsf'))
                if (strcmp(obj.opts_struct.gnsf_detect_struct, 'true'))
                    obj.model_struct = detect_gnsf_structure(obj.model_struct);
                    generate_get_gnsf_structure(obj.model_struct, obj.opts_struct);
                else
                    obj.model_struct = get_gnsf_structure(obj.model_struct);
                end
            end

            % detect cost type
            if (strcmp(obj.model_struct.cost_type, 'auto'))
                obj.model_struct = detect_cost_type(obj.model_struct, 0);
            end
            if (strcmp(obj.model_struct.cost_type_e, 'auto'))
                obj.model_struct = detect_cost_type(obj.model_struct, 1);
            end

            % check if mex interface exists already
            if is_octave()
                mex_exists = exist( fullfile(obj.opts_struct.output_dir,...
                    '/ocp_create.mex'), 'file');
            else
                mex_exists = exist( fullfile(obj.opts_struct.output_dir,...
                    '/ocp_create.mexa64'), 'file');
            end

            if mex_exists
                % recompile if qpOAES is needed and not linked against in existing interface
                recompile_with_qpOASES = false;
                if ~isempty(strfind(obj.opts_struct.qp_solver,'qpoases'))
                    flag_file = fullfile(obj.opts_struct.output_dir, '_compiled_with_qpoases.txt');
                    recompile_with_qpOASES = ~exist(flag_file, 'file');
                end
            end

            % compile mex interface (without model dependency)
            if ( strcmp(obj.opts_struct.compile_interface, 'true') || ~mex_exists  ...
                  || recompile_with_qpOASES  )
                ocp_compile_interface(obj.opts_struct);
            end

            obj.C_ocp = ocp_create(obj.model_struct, obj.opts_struct);

            % generate and compile casadi functions
            if (strcmp(obj.opts_struct.codgen_model, 'true'))
                ocp_generate_casadi_ext_fun(obj.model_struct, obj.opts_struct);
            end

            obj.C_ocp_ext_fun = ocp_create_ext_fun();

            % compile mex with model dependency & set pointers for external functions in model
            obj.C_ocp_ext_fun = ocp_set_ext_fun(obj.C_ocp, obj.C_ocp_ext_fun, obj.model_struct, obj.opts_struct);

            % precompute
            ocp_precompute(obj.C_ocp);

        end


        function solve(obj)
            ocp_solve(obj.C_ocp);
        end



        function eval_param_sens(obj, field, stage, index)
            ocp_eval_param_sens(obj.C_ocp, field, stage, index);
        end


        function set(varargin)
            if nargin==3
                obj = varargin{1};
                field = varargin{2};
                value = varargin{3};
                ocp_set(obj.model_struct, obj.opts_struct, obj.C_ocp, obj.C_ocp_ext_fun, field, value);
            elseif nargin==4
                obj = varargin{1};
                field = varargin{2};
                value = varargin{3};
                stage = varargin{4};
                ocp_set(obj.model_struct, obj.opts_struct, obj.C_ocp, obj.C_ocp_ext_fun, field, value, stage);
            else
                disp('acados_ocp.set: wrong number of input arguments (2 or 3 allowed)');
            end
        end



        function value = get(varargin)
            if nargin==2
                obj = varargin{1};
                field = varargin{2};
                value = ocp_get(obj.C_ocp, field);
            elseif nargin==3
                obj = varargin{1};
                field = varargin{2};
                stage = varargin{3};
                value = ocp_get(obj.C_ocp, field, stage);
            else
                disp('acados_ocp.get: wrong number of input arguments (1 or 2 allowed)');
            end
        end



        function print(varargin)
            if nargin < 2
                field = 'stat';
            else
                field = varargin{2};
            end

            obj = varargin{1};
            ocp_solver_string = obj.opts_struct.nlp_solver;

            if strcmp(field, 'stat')
                stat = obj.get('stat');
                if strcmp(ocp_solver_string, 'sqp')
                    fprintf('\niter\tres_stat\tres_eq\t\tres_ineq\tres_comp\tqp_stat\tqp_iter');
                    if size(stat,2)>7
                        fprintf('\tqp_res_stat\tqp_res_eq\tqp_res_ineq\tqp_res_comp');
                    end
                    fprintf('\n');
                    for jj=1:size(stat,1)
                        fprintf('%d\t%e\t%e\t%e\t%e\t%d\t%d', stat(jj,1), stat(jj,2), stat(jj,3), stat(jj,4), stat(jj,5), stat(jj,6), stat(jj,7));
                        if size(stat,2)>7
                            fprintf('\t%e\t%e\t%e\t%e', stat(jj,8), stat(jj,9), stat(jj,10), stat(jj,11));
                        end
                        fprintf('\n');
                    end
                    fprintf('\n');
                elseif strcmp(ocp_solver_string, 'sqp_rti')
                    fprintf('\niter\tqp_status\tqp_iter\n');
                    for jj=1:size(stat,1)
                        fprintf('%d\t%d\t\t%d', stat(jj,1), stat(jj,2), stat(jj,3));
                        fprintf('\n');
                    end
                end

            else
                fprintf('unsupported field in function print of acados_ocp, got %s', field);
                keyboard
            end

        end


        function delete(obj)
            if ~isempty(obj.C_ocp_ext_fun)
                ocp_destroy_ext_fun(obj.model_struct, obj.C_ocp, obj.C_ocp_ext_fun);
            end
            if ~isempty(obj.C_ocp) 
                ocp_destroy(obj.C_ocp);
            end
        end


    end % methods



end % class


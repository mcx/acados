%
% Copyright (c) The acados authors.
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

function sim = setup_sim(obj)
    % create
    sim = acados_template_mex.AcadosSim();

    % aliases of frontend obj
    model = obj.model_struct;
    opts = obj.opts_struct;

    % file structures
    acados_folder = getenv('ACADOS_INSTALL_DIR');
    sim.acados_include_path = [acados_folder, '/include'];
    sim.acados_lib_path = [acados_folder, '/lib'];
    sim.shared_lib_ext = '.so';
    if ismac()
        sim.shared_lib_ext = '.dylib';
    end
    sim.json_file = 'acados_sim.json';
    sim.cython_include_dirs = [];  % only useful for python interface
    sim.code_export_directory = fullfile(pwd(), 'c_generated_code');

    % dimensions
    sim.dims.nx = model.dim_nx;
    sim.dims.nu = model.dim_nu;
    sim.dims.nz = model.dim_nz;
    sim.dims.np = model.dim_np;
    if isfield(model, 'dim_gnsf_nx1')
        sim.dims.gnsf_nx1 = model.dim_gnsf_nx1;
        sim.dims.gnsf_nz1 = model.dim_gnsf_nz1;
        sim.dims.gnsf_nout = model.dim_gnsf_nout;
        sim.dims.gnsf_ny = model.dim_gnsf_ny;
        sim.dims.gnsf_nuhat = model.dim_gnsf_nuhat;
    end

    % model dynamics
    sim.model.name = model.name;
    if strcmp(opts.method, 'erk')
        sim.model.f_expl_expr = model.dyn_expr_f;
    elseif strcmp(opts.method, 'irk')
        if strcmp(model.ext_fun_type, 'casadi')
            sim.model.f_impl_expr = model.dyn_expr_f;
        elseif strcmp(model.ext_fun_type, 'generic')
            sim.model.dyn_generic_source = model.dyn_generic_source;
        end
    elseif strcmp(opts.method, 'discrete')
        sim.model.dyn_ext_fun_type = model.ext_fun_type;
        if strcmp(model.ext_fun_type, 'casadi')
            sim.model.f_phi_expr = model.dyn_expr_phi;
        elseif strcmp(model.ext_fun_type, 'generic')
            sim.model.dyn_generic_source = model.dyn_generic_source;
            if isfield(model, 'dyn_disc_fun_jac_hess')
                sim.model.dyn_disc_fun_jac_hess = model.dyn_disc_fun_jac_hess;
            end
            if isfield(model, 'dyn_disc_fun_jac')
                sim.model.dyn_disc_fun_jac = model.dyn_disc_fun_jac;
            end
            sim.model.dyn_disc_fun = model.dyn_disc_fun;
        end
    elseif strcmp(opts.method, 'irk_gnsf')
        sim.model.gnsf.A = model.dyn_gnsf_A;
        sim.model.gnsf.B = model.dyn_gnsf_B;
        sim.model.gnsf.C = model.dyn_gnsf_C;
        sim.model.gnsf.E = model.dyn_gnsf_E;
        sim.model.gnsf.c = model.dyn_gnsf_c;
        sim.model.gnsf.A_LO = model.dyn_gnsf_A_LO;
        sim.model.gnsf.B_LO = model.dyn_gnsf_B_LO;
        sim.model.gnsf.E_LO = model.dyn_gnsf_E_LO;
        sim.model.gnsf.c_LO = model.dyn_gnsf_c_LO;

        sim.model.gnsf.L_x = model.dyn_gnsf_L_x;
        sim.model.gnsf.L_u = model.dyn_gnsf_L_u;
        sim.model.gnsf.L_xdot = model.dyn_gnsf_L_xdot;
        sim.model.gnsf.L_z = model.dyn_gnsf_L_z;

        sim.model.gnsf.expr_phi = model.dyn_gnsf_expr_phi;
        sim.model.gnsf.expr_f_lo = model.dyn_gnsf_expr_f_lo;

        sim.model.gnsf.ipiv_x = model.dyn_gnsf_ipiv_x;
        sim.model.gnsf.idx_perm_x = model.dyn_gnsf_idx_perm_x;
        sim.model.gnsf.ipiv_z = model.dyn_gnsf_ipiv_z;
        sim.model.gnsf.idx_perm_z = model.dyn_gnsf_idx_perm_z;
        sim.model.gnsf.ipiv_f = model.dyn_gnsf_ipiv_f;
        sim.model.gnsf.idx_perm_f = model.dyn_gnsf_idx_perm_f;

        sim.model.gnsf.nontrivial_f_LO = model.dyn_gnsf_nontrivial_f_LO;
        sim.model.gnsf.purely_linear = model.dyn_gnsf_purely_linear;

        sim.model.gnsf.y = model.sym_gnsf_y;
        sim.model.gnsf.uhat = model.sym_gnsf_uhat;
    else
        error(['integrator ', opts.method, ' not support for templating backend.'])
    end

    sim.model.x = model.sym_x;
    sim.model.u = model.sym_u;
    sim.model.z = model.sym_z;
    sim.model.xdot = model.sym_xdot;
    sim.model.p = model.sym_p;

    % options
    if strcmp(upper(opts.method), 'IRK_GNSF')
        sim.sim_options.integrator_type = 'GNSF';
    else
        sim.sim_options.integrator_type = upper(opts.method);
    end
    sim.sim_options.collocation_type = upper(opts.collocation_type);
    sim.sim_options.sim_method_num_stages = opts.num_stages;
    sim.sim_options.sim_method_num_steps = opts.num_steps;
    sim.sim_options.sim_method_newton_iter = opts.newton_iter;
    sim.sim_options.sim_method_newton_tol = opts.newton_tol;
    sim.sim_options.Tsim = model.T;
    sim.sim_options.sens_forw = str2bool(opts.sens_forw);
    sim.sim_options.sens_adj = str2bool(opts.sens_adj);
    sim.sim_options.sens_algebraic = str2bool(opts.sens_algebraic);
    sim.sim_options.sens_hess = str2bool(opts.sens_hess);
    sim.sim_options.output_z = str2bool(opts.output_z);
    sim.sim_options.sim_method_jac_reuse = str2bool(opts.jac_reuse);
    sim.sim_options.ext_fun_compile_flags = opts.ext_fun_compile_flags;

    % parameters
    if model.dim_np > 0
        if isempty(opts.parameter_values)
            warning(['opts_struct.parameter_values are not set.', ...
                        10 'Using zeros(np,1) by default.' 10 'You can update them later using set().']);
            sim.parameter_values = zeros(model.dim_np,1);
        else
            sim.parameter_values = opts.parameter_values(:);
        end
    end
end


function b = str2bool(s)
    if strcmp(lower(s), 'false')
        b = false;
    elseif strcmp(lower(s), 'true')
        b = true;
    else
        error('either true or false.');
    end
end

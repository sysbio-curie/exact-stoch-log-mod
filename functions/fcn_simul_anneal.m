function [fcn_statsol_sum_sq_dev,fcn_statsol_values]=fcn_simul_anneal(y_data,x0,stg_table,nodes,predictor_names)

% create function that calculates sum of squared deviations, composed of different fcns
fcn_statsol_sum_sq_dev=@(x)sum((y_data - fcn_calc_init_stat_nodevals(x0,...
    split_calc_inverse(fcn_build_trans_matr(stg_table,fcn_trans_rates_table(nodes,'uniform',[],[],predictor_names,x),''),...
    fcn_trans_rates_table(nodes,'uniform',[],[],predictor_names,x),x0),'' )).^2);
% function to calculate stationary values
fcn_statsol_values=@(x)fcn_calc_init_stat_nodevals(x0,...
    split_calc_inverse(fcn_build_trans_matr(stg_table,fcn_trans_rates_table(nodes,'uniform',[],[],predictor_names,x),''),...
    fcn_trans_rates_table(nodes,'uniform',[],[],predictor_names,x),x0),'' );

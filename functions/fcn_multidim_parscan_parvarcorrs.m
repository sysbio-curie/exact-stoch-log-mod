function [corr_matr,p_matrix_vars]=fcn_multidim_parscan_parvarcorrs(plot_type_flag,all_par_vals_lhs,scan_values,...
                                        nodes,sel_nodes,scan_params,scan_params_up_down,regr_type,param_settings)

% CORRELATIONS BETWEEN VARIABLES
if strcmp(plot_type_flag(1),'var') || strcmp(plot_type_flag(1),'var_var') 

[corr_matr,p_matrix_vars]=corrcoef(scan_values); corr_matr(p_matrix_vars>0.05)=NaN; corr_matr=triu(corr_matr); corr_matr(corr_matr==0)=NaN;
    
% HEATMAP
if strcmp(plot_type_flag(2),'heatmap')

if ~isempty(sel_nodes); var_selection=sel_nodes; else var_selection=1:numel(nodes); end
num_size_plot=param_settings(1); fontsize=param_settings(2);
heatmap(corr_matr(var_selection(1:end-1),var_selection(2:end)),nodes(var_selection(2:end)),nodes(var_selection(1:end-1)),...
  '%0.2f','TickAngle',90,'Colormap','redblue','MinColorValue',-1,'MaxColorValue',1,...
  'GridLines','-','FontSize',num_size_plot,'ShowAllTicks',true,'NaNColor',[1 1 1]); set(gca,'FontSize',fontsize)
title('correlation coefficients between variables', 'FontWeight','normal','FontSize', param_settings(2) ) 

% VAR-VAR SCATTERPLOT
elseif strcmp(plot_type_flag(2),'scatter')
varcorr_plot_indices=fcn_norep_perms(sel_nodes);
n_pars=size(varcorr_plot_indices,1); round_sqrt=round(sqrt(n_pars));
if round_sqrt^2 >= n_pars
    n_row_plot=round_sqrt; n_col_plot=round_sqrt;
else
    n_row_plot=round_sqrt; n_col_plot=round_sqrt+1;
end

fontsize_labels=param_settings(1); fontsize_title=param_settings(2);
for k=1:size(varcorr_plot_indices,1)
   subplot(n_row_plot,n_col_plot,k); 
   scatter(scan_values(:,varcorr_plot_indices(k,1)),scan_values(:,varcorr_plot_indices(k,2))); 
   xlim([0 1]); ylim([0 1]); xlabel(strrep(nodes{varcorr_plot_indices(k,1)},'_','\_'), 'FontSize', fontsize_labels ); 
    ylabel(nodes{varcorr_plot_indices(k,2)},'FontSize',fontsize_labels,'Interpreter','none');
    [corr_val,p_val] = corr(scan_values(:,varcorr_plot_indices(k,1)),scan_values(:,varcorr_plot_indices(k,2)));
    title(strcat('\rho=',num2str(round(corr_val,2)), ', p=',num2str(round(p_val,3))), 'FontWeight','normal','FontSize', fontsize_title )
end

else
    error('Enter ''scatter'' or ''heatmap'' for <plot_type_flag>.')
end

% PAR-VAR PLOT
elseif strcmp(plot_type_flag(1),'par') || strcmp(plot_type_flag(1),'par_var') 
    % disp('regression between parameters and variable values')
    [~,~,predictor_names] = fcn_get_trans_rates_tbl_inds(scan_params,scan_params_up_down,nodes);
    % disp(strcat(predictor_names,', ',sampling_type))

r_squared=zeros(numel(sel_nodes),numel(predictor_names)); slope_intercept=cell(numel(sel_nodes),numel(predictor_names));
for k=1:numel(sel_nodes);
    for par_c=1:numel(predictor_names)
if strfind(regr_type,'log')
    x=log(all_par_vals_lhs(:,par_c)); str_regr_type=strcat(' (',regr_type,' of)');
else
    x=all_par_vals_lhs(:,par_c); str_regr_type=[];
end
y=scan_values(:,sel_nodes(k));
p=polyfit(x,y,1); SSresid=sum((y - (p(1)*x + p(2))).^2); SStotal=( length(y)-1 )*var(y); 
r_squared(k,par_c)=1-SSresid/SStotal; slope_intercept{k,par_c}=p;
% rsq_adj(k,par_c)=1-SSresid/SStotal*( length(y)-1)/(length(y)-length(p) );
    end
end

corr_matr=r_squared; p_matrix_vars=slope_intercept;
 
if strcmp(plot_type_flag(3),'r_sq') || strcmp(plot_type_flag(3),'r_squared')
    val_to_plot=r_squared; min_col_val=0;
    if ~isnan(param_settings(2)); maxval_color=param_settings(2); else maxval_color=1.05*max(abs(val_to_plot(:))); end
    title_text=strcat('R^2 (linear regression of variables as a fcn of',str_regr_type,' parameters)');
elseif strcmp(plot_type_flag(3),'slope')
    val_to_plot=cellfun(@(v)v(1),slope_intercept); min_col_val=-1.1*max(abs(val_to_plot(:))); maxval_color=abs(min_col_val);
    title_text='Regression coefficient (slope) of variables as a fcn of parameters';
end

if strcmp(plot_type_flag(2),'heatmap')
    num_size_plot=param_settings(1); 

% HEATMAP
heatmap(val_to_plot',nodes(sel_nodes),predictor_names,'%0.2f','TickAngle',90,'Colormap','redblue',...
    'MinColorValue',min_col_val,'MaxColorValue',maxval_color,'GridLines','-','FontSize',num_size_plot,'ShowAllTicks',true,'colorbar',true)
set(gca,'FontSize',param_settings(1)); 
title(title_text, 'Fontweight','normal', 'FontSize',param_settings(1)*1.4) 

elseif strcmp(plot_type_flag(2),'lineplot') || strcmp(plot_type_flag(2),'line')
plot(1:numel(predictor_names),val_to_plot,'LineWidth',2,'Marker','o'); set(gca,'XTick',1:numel(predictor_names)); 
set(gca,'xticklabel',predictor_names,'Interpreter','none','FontSize',param_settings(1)); 
legend(nodes(sel_nodes),'FontWeight','normal','FontSize',param_settings(1),'Interpreter','none','Interpreter','none'); 
title(title_text, 'Fontweight','normal', 'FontSize',param_settings(1)*1.4) 
end

end
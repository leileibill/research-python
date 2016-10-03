clear
close all
clc
scale = 2;
set_figure_style_pre(2.5);
%%  Load data
to_plot = [ 90 500 20; ...
            75 500 20; ...
            50 500 20; ...
            ];
x_axis = 'iout';
y_axis = 'loss';
Marker = {'^-','o-','x-','s-','-+','.-'};
num_to_plot = length(to_plot(:,1));
legend_info = {};
for index = 1:num_to_plot
    x = struct2cell(load('chip_eff_data_180',sprintf('%s_d%i_f%i_dt%i',x_axis,to_plot(index,1),to_plot(index,2),to_plot(index,3))));
    y = struct2cell(load('chip_eff_data_180',sprintf('%s_d%i_f%i_dt%i',y_axis,to_plot(index,1),to_plot(index,2),to_plot(index,3))));
    vout = struct2cell(load('chip_eff_data_180',sprintf('%s_d%i_f%i_dt%i','vout',to_plot(index,1),to_plot(index,2),to_plot(index,3))));
    x = x{1};
    y = y{1};

    loglog(x,y,Marker{index});
    hold on;
    legend_info{index} = sprintf('$V_{{out}}$ = %0.2f V',mean(vout{1}));
end
xlim([0 1.6])
% ylim([40 100])
% plot([0.1 1], [0.01 1])
% plot([0.01 1], [0.01 1])
xlabel('Output current (A)')
ylabel('Power loss (W)')
legend(legend_info,'Location','SouthEast');


%% Estimated
for index = 1:num_to_plot
    L = 180e-9;
    duty = to_plot(index,1)/100;
    frequency = to_plot(index,2)*1e3;
    dt = to_plot(index,3)*1e-9;
    x_sim = 1e-2:1e-2:2;
    ripple = duty*(1-duty)/(2*frequency*L);
    ploss_cond = (100+x_sim*60)*1e-3.*(x_sim.^2.+ripple^2/12);
    ploss_deadtime = dt*2*frequency.*(0.6+x_sim*0.1).*(abs(x_sim-ripple)+abs(x_sim+ripple))/2;
    % ploss_deadtime = 0;
    y_sim =  ploss_cond + ploss_deadtime;
    plot(x_sim,y_sim,'--');
end






set_figure_style(2.3);
resize_figure(scale,0.65);
% export_figure('eff_180','png')
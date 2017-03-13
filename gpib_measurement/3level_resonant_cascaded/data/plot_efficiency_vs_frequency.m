clear
close all
clc
scale = 2;
set_figure_style_pre();
plot_type = 'efficiency';
stage = 'first_stage';
Vin = 50;

to_plot = { 1100 16; ...
            1000 16; ...
            1000 8; ...
            };
%     x_axis = 'iout';
Marker = {'^-','o-','x-','s-','-+','.-'};
num_to_plot = length(to_plot(:,1));
legend_info = {};

for index = 1:num_to_plot

    file = sprintf('./%s/3level_period%i_dead%i.dat',... 
        stage,to_plot{index,1},to_plot{index,2})
    data = csvread(file,1,0);
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,[0; rout],Marker{index});
    end
    hold on;
    legend_info{index} = sprintf('Period = %i, Deadtime = %i',... 
        to_plot{index,1},to_plot{index,2})
end


if strcmp(plot_type,'loss') == 1
    ylim([0.1 10])
    xlim([0.1 10])
    ylabel('Power loss (W)')
    plot([1 10], [0.1 10], '--')
    plot([0.1 10], [0.1 10], '--')
elseif strcmp(plot_type,'efficiency') == 1
    ylim([97 100])
%     xlim([00 2])
    ylabel('Efficiency (\%)')
else
    ylim([0 0.2])
    xlim([0.5 2])
    ylabel('Output resistance ($\Omega$)')   
end



xlabel('Output current (A)')

legend(legend_info,'Location','Best');

set_figure_style();
resize_figure();


export_figure('figs/eff','png')
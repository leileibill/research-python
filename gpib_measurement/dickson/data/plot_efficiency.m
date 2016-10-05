clear
close all
clc
scale = 2;
set_figure_style_pre();
plot_type = 'rout';

to_plot = { ... % 50 50 250 20 ''; ...
            ... % 50 50' 250 20 '_diode'; ...
            ... % 90 80 250 20 ''; ...
            ... % 90 50 250 20 ''; ...
            90 80 250 20 '_diode'; ...
            };
x_axis = 'iout';
y_axis = 'loss';
Marker = {'^-','o-','x-','s-','-+','.-'};
num_to_plot = length(to_plot(:,1));
legend_info = {};


for index = 1:num_to_plot

    file = sprintf('SC_Regulation_%iV_%i_%ik_%iOhm%s.dat',to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5})
    data = csvread(file,1,0);
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
    rout = (vin/6*0.8 - vout)./iout;
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,rout,Marker{index});
    end
    hold on;
    legend_info{index} = sprintf('%iV %i %ik %iOhm %s',to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5});
end

set_figure_style();
resize_figure();

if strcmp(plot_type,'loss') == 1
    ylim([0.1 10])
    xlim([0.1 10])
    ylabel('Power loss (W)')
    plot([1 10], [0.1 10], '--')
    plot([0.1 10], [0.1 10], '--')
elseif strcmp(plot_type,'loss') == 1
    ylim([90 97])
    xlim([0.5 4])
    ylabel('Efficiency (\%)')
else
%     ylim([90 97])
    xlim([0.5 4])
    ylabel('Output resistance ($\Omega$)')   
end



xlabel('Output current (A)')

legend(legend_info,'Location','Best');
return

% export_figure('eff_180','png')
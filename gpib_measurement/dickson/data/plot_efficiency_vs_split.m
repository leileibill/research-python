clear
close all
clc
scale = 2;
set_figure_style_pre(2);
plot_type = 'efficiency';

legend_info = {};
Marker = {'^-','o-','x-','s-','-+','.-'};

inductor = '5600n';

to_plot = { 90 80 250 20 66; ...
            90 80 250 20 75; ...
            90 80 250 20 80; ...
            90 80 250 20 85; ...      
            };

%     x_axis = 'iout';

num_to_plot = length(to_plot(:,1));



for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_Regulation_%iV_%i_%ik_%iOhm_diode%i.dat',... 
        inductor,to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5})
    data = csvread(file,1,0);
    duty = to_plot{index,2}/100;
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
    rout = (vin/6*duty - vout)./iout;
    
    if strcmp(plot_type,'loss') == 1
        plot(iout, ploss,Marker{1});
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{1});
    else
        plot(iout,rout,Marker{1});
    end
    hold on;
    legend_info{index} = sprintf('5.6uH %iV 0.%i %ikHz %i$\\Omega$ %i',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5})
end


%%
if strcmp(plot_type,'loss') == 1
    ylim([0.1 10])
    xlim([0.1 10])
    ylabel('Power loss (W)')
    plot([1 10], [0.1 10], '--')
    plot([0.1 10], [0.1 10], '--')
elseif strcmp(plot_type,'efficiency') == 1
    ylim([90 97])
    xlim([0 5])
    ylabel('Efficiency (\%)')
else
    ylim([0.12 0.16])
    xlim([0.5 5])
    ylabel('Output resistance ($\Omega$)')   
end



xlabel('Output current (A)')

legend(legend_info,'Location','Best');

set_figure_style();
resize_figure();


return

% export_figure('eff_180','png')
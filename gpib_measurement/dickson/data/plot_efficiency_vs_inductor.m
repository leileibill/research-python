clear
close all
clc
scale = 2;
set_figure_style_pre();
plot_type = 'efficiency';

legend_info = {};
Marker = {'^-','o-','x-','s-','-+','.-'};
%%  1000 nH inductor
inductor = '1000n';
to_plot = { 90 80 250 20 '_diode80_deadtime'; ...
            90 80 500 20 '_diode80_deadtime'; ...
            130 55 500 20 '_diode80_deadtime'; ...
            };

%     x_axis = 'iout';

num_to_plot = length(to_plot(:,1));



for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_Regulation_%iV_%i_%ik_%iOhm%s.dat',... 
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
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,rout,Marker{index});
    end
    hold on;
    legend_info{index} = sprintf('1uH %iV 0.%i %ikHz %i$\\Omega$ %s',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5}(2:end))
end

%%  5600 nH inductor
inductor = '5600n';
to_plot = { 130 55 250 20 '_diode80'; ...
            ... %150 48 250 20 '_diode'; ...
            ... %150 48 300 20 '_diode'; ...
            ... % 90 80 250 20 ''; ...
            ... % 90 50 250 20 ''; ...
            ... %90 80 250 20 '_diode'; ...
            90 80 250 20 '_diode75'; ...
            };
num_to_plot = length(to_plot(:,1));        
for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_Regulation_%iV_%i_%ik_%iOhm%s.dat',... 
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
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,rout,Marker{index});
    end
    hold on;
    legend_info{end+1} = sprintf('5.6uH %iV 0.%i %ikHz %i$\\Omega$ %s',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5}(2:end))
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
    ylim([0 0.2])
    xlim([0.0 5])
    ylabel('Output resistance ($\Omega$)')   
end



xlabel('Output current (A)')

legend(legend_info,'Location','Best');

set_figure_style();
resize_figure();


return

% export_figure('eff_180','png')
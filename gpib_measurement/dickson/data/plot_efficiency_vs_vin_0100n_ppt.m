clear
close all
clc
scale = 2;
set_figure_style_pre();
plot_type = 'efficiency';
inductor = '0100n';


to_plot = { 50 375 20 70 '_deadtime3';...   
            74 375 20 70 '_deadtime3';...            
            };
%     x_axis = 'iout';
Marker = {'^--','o--','x-','s-','-+','.-'};
num_to_plot = length(to_plot(:,1));
legend_info = {};


for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_ZCS_%iV_%ik_%iOhm_diode%i%s.dat',... 
        inductor,to_plot{index,1},to_plot{index,2},to_plot{index,3}, ...
        to_plot{index,4},to_plot{index,5})
    data = csvread(file,1,0);
    duty = to_plot{index,2}/100;
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
%     rout = (vin/6*duty - vout)./iout;
    rout = -diff(vout)./diff(iout);
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,[0; rout],Marker{index});
    end
    hold on;
    legend_info{index} = sprintf('ZCS %iV %ikHz %s',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,5}(2:end))
end


to_plot = {50 375 20 70 4 2 12;...            
%            74 375 20 70 4 2 12;...    
           74 375 20 80 4 2 12;...
            };
%     x_axis = 'iout';
Marker = {'^-','o-','x--','s--','--+','.--'};
num_to_plot = length(to_plot(:,1));
ax = gca;
ax.ColorOrderIndex = 1;

for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_ZVS_%iV_%ik_%iOhm_diode%i_%id1_%id2_%id3.dat',... 
        inductor,to_plot{index,1},to_plot{index,2},to_plot{index,3}, ...
        to_plot{index,4},to_plot{index,5},to_plot{index,6},to_plot{index,7})
    data = csvread(file,1,0);
    duty = to_plot{index,2}/100;
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
%     rout = (vin/6*duty - vout)./iout;
    rout = -diff(vout)./diff(iout);
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss);
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,[0; rout],Marker{index});
    end
    hold on;
    legend_info{end+1} = sprintf('ZVS %iV %ikHz d1=%i d2=%i d3=%i',... 
        to_plot{index,1},to_plot{index,2}, ...
        to_plot{index,5},to_plot{index,6},to_plot{index,7})
end


if strcmp(plot_type,'loss') == 1
    ylim([0.1 10])
    xlim([0.1 10])
    ylabel('Power loss (W)')
    plot([1 10], [0.1 10], '--')
    plot([0.1 10], [0.1 10], '--')
elseif strcmp(plot_type,'efficiency') == 1
    ylim([90 98])
    xlim([00 3])
    ylabel('Efficiency (\%)')
else
    ylim([0 0.3])
    xlim([0.5 3])
    ylabel('Output resistance ($\Omega$)')   
end



xlabel('Output current (A)')

% legend(legend_info,'Location','Best');
legend('ZCS 50 V','ZCS 75 V','ZVS 50 V','ZVS 75 V','Location','Best');
set_figure_style();
resize_figure();
% export_figure(sprintf('figs/eff_%iV_1000n_frequency',Vin),'png')
export_figure('eff_zvs','pdf,png')
clear
close all
clc
scale = 2;
set_figure_style_pre(2);
plot_type = 'loss';

legend_info = {};
Marker = {'^-','o-','x-','s-','-+','.-'};

inductor = '1000n';
to_compare = 'vin';

if strcmp(inductor, '5600n') ==1
    L = 5.6e-6;
    if strcmp(to_compare, 'vin') == 1
        to_plot = { 90 80 250 20 80 ''; ...
                    130 55 250 20 80 '';...
                    150 48 250 20 '' '';...
                    };
    elseif strcmp(to_compare, 'frequency') ==1
        to_plot = { 90 80 250 20 80 ''; ...
                    90 80 300 20 80 '';...
                    90 80 375 20 80 '';...
                };
    end
elseif strcmp(inductor, '1000n') ==1
    L = 1.0e-6;
    if strcmp(to_compare, 'vin') == 1
%         to_plot = { 90 80 500 20 80 '_deadtime'; ...
%                     130 55 500 20 80 '_deadtime';...
%                     ... %150 48 250 20 80 'deadtime';...
%                     };
        to_plot = { 90 80 250 20 80 '_deadtime'; ...
                    130 55 250 20 90 '_deadtime';...
                    ... %150 48 250 20 80 'deadtime';...
                    };                
    elseif strcmp(to_compare, 'frequency') ==1
        to_plot = { 90 80 250 20 80 '_deadtime'; ...
                    90 80 500 20 80 '_deadtime';...
                    90 80 700 20 80 '_deadtime';...
                };
    end
end
%     x_axis = 'iout';

num_to_plot = length(to_plot(:,1));


%% Measurement
for index = 1:num_to_plot

    file = sprintf('./L_%s/SC_Regulation_%iV_%i_%ik_%iOhm_diode%i%s.dat',... 
        inductor,to_plot{index,1},to_plot{index,2},to_plot{index,3}, ...
        to_plot{index,4},to_plot{index,5},to_plot{index,6})
    data = csvread(file,1,0);
    duty = to_plot{index,2}/100;
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);
    efficiency = data(:,7);
    ploss = data(:,5) - data(:,6);
    rout = (vin/6*duty - vout)./iout;
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss,Marker{1});
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,Marker{index});
    else
        plot(iout,rout,Marker{1});
    end
    hold on;
    legend_info{index} = sprintf('Measurement: 5.6uH %iV 0.%i %ikHz %i$\\Omega$ %i',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5});
end

%%      Calculation

ax = gca;
ax.ColorOrderIndex = 1;
for index = 1:num_to_plot

    fsw = to_plot{index,3}*1e3;
    file = sprintf('./L_%s/SC_Regulation_%iV_%i_%ik_%iOhm_diode%i%s.dat',... 
        inductor,to_plot{index,1},to_plot{index,2},to_plot{index,3}, ...
        to_plot{index,4},to_plot{index,5},to_plot{index,6})
    data = csvread(file,1,0);
    duty = to_plot{index,2}/100;
    vin = data(:,1);
    vout = data(:,3);
    iout = data(:,4);     
    pin = data(:,5);
      
    [ploss, Pcond, Pind, Poverlap, Pcoss] = calculate_loss(vin,iout,fsw,duty,L);      % total loss
    
    
    efficiency = (pin - ploss)./pin;
    
%     rout = (vin/6*duty - vout)./iout;
    
    if strcmp(plot_type,'loss') == 1
        loglog(iout, ploss,'--');
    elseif strcmp(plot_type,'efficiency') == 1
        plot(iout,efficiency*100,'--');
    else
        plot(iout,rout,'--');
    end
    hold on;
    legend_info{end+1} = sprintf('Calculation: 5.6uH %iV 0.%i %ikHz %i$\\Omega$ %i',... 
        to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4},to_plot{index,5});
end

%%
if strcmp(plot_type,'loss') == 1
    ylim([0.1 10])
    xlim([0.1 10])
    ylabel('Power loss (W)')
%     plot([1 10], [0.1 10], '--')
%     plot([0.1 10], [0.1 10], '--')
elseif strcmp(plot_type,'efficiency') == 1
    ylim([90 98])
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
resize_figure(4);


return

% export_figure('eff_180','png')
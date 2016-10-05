clear
close all
clc
scale = 2;
set_figure_style_pre();


to_plot = { 50 '0p5' 250 100; ...
            50 '0p5' 250 20; ...
            90 '0p5' 250 20; ...
            90 '0p8' 250 20; ...
            };
x_axis = 'iout';
y_axis = 'loss';
Marker = {'^-','o-','x-','s-','-+','.-'};
num_to_plot = length(to_plot(:,1));
legend_info = {};
for index = 1:num_to_plot

    file = sprintf('SC_Regulation_%iV_%s_%ik_%iOhm.dat',to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4})
    data = csvread(file,1,0);
    iout = data(:,4);
    efficiency = data(:,7);
    

    plot(iout,efficiency,Marker{index});
    hold on;
    legend_info{index} = sprintf('%iV %s %ik %iOhm',to_plot{index,1},to_plot{index,2},to_plot{index,3},to_plot{index,4});
end

set_figure_style();
resize_figure();

ylim([0.9 0.98])


% plot([0.1 1], [0.01 1])
% plot([0.01 1], [0.01 1])
xlabel('Output current (A)')
ylabel('Efficiency (\%)')
legend(legend_info,'Location','SouthEast');
return

% export_figure('eff_180','png')
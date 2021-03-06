clear
close all
clc
scale = 2;
set_figure_style_pre(2);
plot_type = 'loss';

legend_info = {};
Marker = {'^-','o-','x-','s-','-+','.-'};

inductor = '5600n';
if strcmp(inductor, '5600n') ==1
    L = 5.6e-6;
    to_plot = { 90 80 250 20 80; ...
                130 55 250 20 80;...
                150 48 250 20 '';...
                };
elseif strcmp(inductor, '1000n') ==1
    L = 1.0e-6;
%     to_plot = { 90 80 500 20 80; ...
%                 130 55 500 20 80;...
%                 ... %150 48 250 20 '';...
%                 };
    to_plot = { 90 80 250 20 80 ; ...
                90 80 500 20 80 ;...
                90 80 700 20 80 ;...
                };            
end
%     x_axis = 'iout';

num_to_plot = length(to_plot(:,1));



%%      Calculation

for index = 1:num_to_plot
    figure;

    fsw = to_plot{index,3}*1e3;
    duty = to_plot{index,2}/100;
    iout = (0.1:0.01:5)'; 
    vin = to_plot{index,1}*ones(size(iout));
    vout = 12*ones(size(iout));
    
    

    [ploss, Pcond, Pind, Poverlap, Pcoss] = calculate_loss(vin,iout,fsw,duty,L);

    ploss_all = [Pind,  Pcoss , Poverlap, Pcond];
    h = area(iout, ploss_all);
    colors = jet(length(h));
    for index = 1:length(h)
        h(index).FaceColor = colors(index,:);
        h(index).FaceAlpha = 0.618;
    end

    legend_info = {'Inductor loss' 'Coss loss ' 'Overlap loss' 'Switch conduction loss' };
    
    xlim([0 5])
    ylim([0 4])
    ylabel('Power loss (W)')

    xlabel('Output current (A)')

    legend(legend_info,'Location','Best');
    reorderLegend([1 2 3 4])
    set_figure_style();
    resize_figure(2);
end

%%




% export_figure('eff_180','png')
% This script tries to fit the core loss data of the inductor

clc;
close all;
clear;

L = 5.6e-6;
set_figure_style_pre();
%% 250 kHz data
fsw = 250e3;
vin = [90 105 130 150];
vout = 12;
duty = vout./(vin/6);
ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
loss = [0.026 0.091 0.212, 0.287];  % loss obtained from coilcraft website

plot(ripple,loss,'-s')
hold on;

%% 300 kHz data
fsw = 300e3;
ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
loss = [0.029 0.079 0.171 0.239];  % loss obtained from coilcraft website

plot(ripple,loss,'-s')
hold on;

%% 375 kHz data
fsw = 375e3;
ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
loss = [0.023 0.065 0.139 0.199];  % loss obtained from coilcraft website

plot(ripple,loss,'-s')
hold on;

%% Fitting

ax = gca;
ax.ColorOrderIndex = 1;

alpha = 1.4;
beta = 2.35;
k = 0.1/2.25/(250e3^alpha);

fsw_range = [250e3 300e3 375e3];
for index = 1:length(fsw_range)
    fsw = fsw_range(index);
    vin = [90 105 130 150];
    vout = 12;
    duty = vout./(vin/6);
    ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2)
    
    loss_cal = k*(fsw.^alpha).*(ripple.^beta);
    plot(ripple,loss_cal,'--')
end


%%
xlim([0 2.5])
xlabel('Peak-to-peak current ripple (A)');
ylabel('AC loss (W)')
set_figure_style();
resize_figure;

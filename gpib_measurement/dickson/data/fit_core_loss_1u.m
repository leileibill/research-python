% This script tries to fit the core loss data of the inductor

clc;
close all;
clear;

L = 1.0e-6;
set_figure_style_pre();
%% Common parameters
vin = [90 105 130 150];
vout = 12;
duty = vout./(vin/6);
%% 250 kHz data
% fsw = 250e3;

% ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
% loss = [0.026 0.091 0.212, 0.287];  % loss obtained from coilcraft website
% 
% plot(ripple,loss,'-s')
% hold on;

%% 500 kHz data
fsw = 500e3;
ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
loss = [0.11 0.287 0.6 0.827];  % loss obtained from coilcraft website

plot(ripple,loss,'-s')
hold on;

%% 700 kHz data
fsw = 700e3;
ripple = vin/6.*duty.*(1-duty)./(L.*fsw*2);
loss = [0.081 0.212 0.442 0.612];  % loss obtained from coilcraft website

plot(ripple,loss,'-s')
hold on;

%% Fitting

ax = gca;
ax.ColorOrderIndex = 1;

alpha = 1.35;
beta = 2.11;
k = 0.017/(500e3^alpha);

fsw_range = [500e3 700e3];
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
xlim([0 8])
xlabel('Peak-to-peak current ripple (A)');
ylabel('AC loss (W)')
set_figure_style();
resize_figure;

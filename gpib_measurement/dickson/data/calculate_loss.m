% This function calculates the various loss components of a Dickson
% converter. vector inputs are vin, iout
function [Ploss, Pcond, Pind, Poverlap, Pcoss] = calculate_loss(vin,iout,fsw,duty,L)

    %% switch conduction
    Reff = 0.005 + duty*0.085+(1-duty)*0.004;       % effective resistance in the circuit
    Iripple = duty.*(1-duty).*vin/6./(2*fsw.*L);       % current ripple
    Ilow = iout - Iripple/2;
    Irms2 = iout.^2 + Iripple.^2/12; % RMS current
    Pcond = Irms2*Reff;           % Conduction loss
    dt = 110e-9;        % deadtime
    
    %% Inductor dc and ac loss
    if L ==5.6e-6
        Rdc = 0.03;
        alpha = 1.4;
        beta = 2.35;
        k = 0.0444/(250e3^alpha);
    elseif L == 1.0e-6
        Rdc = 0.011;
        alpha = 1.05;
        beta = 2.11;
        k = 0.017/(500e3^alpha);
    end
    Pcond_L = Irms2*Rdc;
    Pcore = k*(fsw.^alpha).*(Iripple.^beta);
    Pind = Pcore + Pcond_L;   
    
    %% Coss loss
    Vds_data_2007c = [10 20.5 31 40.3 50.8 60 71 80 90.5 98.8];
    Coss_data_2007c = [222 171 135 122 110 102 93.4 87.4 82 78];
    Vds_2007c = vin/6*2;
    Qoss_2007c = Vds_2007c .* interp1(Vds_data_2007c,Coss_data_2007c*1e-12,Vds_2007c);
    
    Vds_data_2015c = [5 10 20 30 40];    
    Coss_data_2015c = [1050 950 700 500 440]; 
    Vds_2015c = vin/6; 
    Qoss_2015c = Vds_2015c .* interp1(Vds_data_2015c,Coss_data_2015c*1e-12,Vds_2015c);
    
    Qoss = 7* Qoss_2007c + 4* Qoss_2015c;
    Pcoss = 0.5*(Vds_2007c.*Qoss_2007c*7 + Vds_2015c.*Qoss_2015c).*fsw;   % Coss switching loss
    if L ==5.6e-6
        
    elseif L == 1.0e-6
        Isoft = -Qoss/dt;      % note that the current is negative
        Pcoss(Ilow<Isoft) = 0;
        x = Ilow>Isoft & Ilow<0;
        Pcoss(x) = Pcoss(x).*(1-Ilow(x)./Isoft(x));
    end  
    
    %% Overlap loss
  
    if L ==5.6e-6
        Poverlap = 5*vin/3.*abs(Ilow)/3*10e-9*fsw;    % Overlap switching loss
%         Poverlap = 5*vin/3.*(abs(iout-Iripple/2)+abs(iout+Iripple/2))/3*4e-9*fsw;    % Overlap switching loss
    elseif L == 1.0e-6
        Poverlap = max(0,5*vin/3.*Ilow/3*4e-9*fsw);    % Overlap switching loss
        % for now, include the body diode loss in the overlap loss
        x = Ilow<Isoft;
        tt = max(0,Qoss./(-Ilow));
        Poverlap(x) = Poverlap(x) + -Ilow(x)*2.2.*(dt-tt(x))*fsw*2;
    end
   
    

    

%     Pbody = 12e-9*(fsw*2)*1*iout;    % diode conduction loss, very small

    %% Total loss
    Ploss = Pcond + Pind + Poverlap + Pcoss;      % total loss
    
end
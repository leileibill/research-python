% This function calculates the various loss components of a Dickson
% converter. vector inputs are vin, iout
function [Ploss, Pcond, Pind, Poverlap, Pcoss] = calculate_loss(vin,iout,fsw,duty,L)

    %% switch conduction
    Reff = 0.005 + duty*0.085+(1-duty)*0.004;       % effective resistance in the circuit
    Iripple = duty.*(1-duty).*vin/6./(2*fsw.*L);       % current ripple
    Ilow = iout - Iripple/2;
    Irms2 = iout.^2 + Iripple.^2/12; % RMS current
    Pcond = Irms2*Reff;           % Conduction loss
    dt = 100e-9;        % deadtime
    
    %% Inductor dc and ac loss
    if L ==5.6e-6
        Rdc = 0.03;
        alpha = 1.4;
        beta = 2.35;
        k = 0.0444/(250e3^alpha);
    elseif L == 1.0e-6
        Rdc = 0.011;
        alpha = 1.35;
        beta = 2.11;
        k = 0.017/(500e3^alpha);
    end
    Pcond_L = Irms2*Rdc;
    Pcore = k*(fsw.^alpha).*(Iripple.^beta);
    Pind = Pcore + Pcond_L;   
    
    %% Coss loss
    Vds_data = [10 20.5 31 40.3 50.8 60 71 80 90.5 98.8];
    Coss_data = [222 171 135 122 110 102 93.4 87.4 82 78];
    Vds = vin/6*2;
    Coss = interp1(Vds_data,Coss_data*1e-12,Vds);
    if L ==5.6e-6
        Pcoss = 7*(vin/3).^2.*Coss.*fsw;   % Coss switching loss
    elseif L == 1.0e-6
        Pcoss = 7*(vin/3).^2.*Coss.*fsw;   % Coss switching loss
        Isoft = -Coss.*vin/dt;      % note that the current is negative
        Pcoss((iout-Iripple/2)<Isoft) = 0;
        x = Ilow>Isoft & Ilow<0;
        Pcoss(x) = Pcoss(x).*(1-Ilow(x)./Isoft(x));
    end  
    
    %% Overlap loss
  
    if L ==5.6e-6
        Poverlap = 5*vin/3.*(abs(iout-Iripple/2)+abs(iout+Iripple/2))/3*4e-9*fsw;    % Overlap switching loss
    elseif L == 1.0e-6
        Poverlap = max(0,5*vin/3.*((iout-Iripple/2))/3*4e-9*fsw);    % Overlap switching loss
        % for now, include the body diode loss in the overlap loss
        x = Ilow<Isoft;
        Poverlap(x) = Poverlap(x) + -Ilow(x)*2*dt*fsw*2;
    end
   
    

    

%     Pbody = 12e-9*(fsw*2)*1*iout;    % diode conduction loss, very small

    %% Total loss
    Ploss = Pcond + Pind + Poverlap + Pcoss;      % total loss
    
end
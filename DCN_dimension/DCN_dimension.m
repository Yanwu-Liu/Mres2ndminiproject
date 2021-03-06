
close all
clear all
clc

% This is the file to calculate physical dimension for the proposed DCN
% with interleaving structure tower panel.

% X: max number of collimator pairs can be horizontally accomodated 
% Nmin: min (maximum)number of nodes vertically when tower and rack is
% separated at Dm
% Nmax: max (maximum)number of nodes vertically when tower and rack is
% separated at Dx

% The "maximum" in brackets means the maximum actuator angle allowed in
% vertical layout is 6.3554 deg (if 2 lenses in a unit) and we are using
% this full angle to move.

% The subscript "min" and "max" means they are determined by separation
% distance between tower and rack





%% 

% To use this file, always specify the following parameters. The calculated
% DCN dimension is exclusive to a certain set of parameters. 
% Change these value to recalculate the entire structure for other
% wavelengths or lenses

%This value may vary according to wavelength. Check MFD_comparison.m for
%zmax at other wavelengths. 
zmax = 6.1506  % theoretical @1550nm

%standard specifications
Rack_Unit =  44.45*10^(-3) 
Rack_Width = 482.6*10^(-3)

%Thorlabs TC18APC1550
lens_L = 33.5 * 10^(-3)
lens_diameter = 14.9 * 10^(-3)
lens_radius = lens_diameter/2

%Edge margin from between outermost lens and Rack edge 
edge_margin = 2 * 10^(-3)
epsilon_margin = 2 * 10^(-3)



%%

%minimum gap between adjacent collimators consider actuator moving angle
%This value is initially unknown so we sweep across from 0 to pi/2 and 
% check for feasibility

alpha = linspace(0.01, 0.5, 1000)*pi;

P_vec = [];
Np_floor_vec = [];

G_vec = [];
X_vec = [];
G_loosen_vec = [];

S_int_vec = [];
Patch_Width_int_vec = [];
sigma_deg_vec = [];
Dm_vec = [];
height_rack_vec = [];
z_req_vec = [];

min_Num_Nodes_vec = [];
Zpath_vec = [];

Dx_vec = [];
Nx_vec = [];

for aa = 1:1:length(alpha)
    
    angle  = alpha(aa); %rad
    g_dash = lens_radius*cos(angle) + lens_L*sin(angle);
    
    %clear gap on both sides
    G = 2*g_dash;
    G_vec = [G_vec  G];

    %maximum number of lenses (including both TX and RX) in a row for a given G
    P = ( (Rack_Width - 2*(edge_margin + g_dash)) / G) + 1;
    P_vec = [P_vec  P];
    
    %integer floored maximum number of lenses (bpth TX and RX)
    Np_floor = floor(P);
    Np_floor_vec = [Np_floor_vec  Np_floor];
    
    %number of transceiver pair supported in a row (same as number of ports in a row)
    X = floor(Np_floor/2);
    X_vec = [X_vec X];
    
    
    %loosen gap on the rack
    G_loosen = (Rack_Width - 2*edge_margin)/(2*X);
    G_loosen_vec = [G_loosen_vec  G_loosen];

   
    %given the X, calculate polygon layout
    theta = pi/X;
    %distance from polygon centre to rack (top view)
    SR = (Rack_Width/2)/tan(theta);
    
    
    
%% Interleaving - horizontal structure
    %calculate the width of patch panel, interleaving
    Patch_Width_int = 2*(edge_margin + g_dash) + (X - 1)*G;
    Patch_Width_int_vec = [Patch_Width_int_vec Patch_Width_int];
    
    
    %distance from polygon centre to patch panel (top view)
    SP = (Patch_Width_int/2)/tan(theta);
    
    %minimum DCN diameter
    S_int = SR - SP;
    S_int_vec = [S_int_vec S_int];
    
    %check if S satisfies zmax*cos(alpha)
    z_req = zmax*cos(angle);
    z_req_vec = [z_req_vec z_req];

    
    
    x1 = Rack_Width/2 - (edge_margin + (1/2)*G_loosen);
    x2 = Patch_Width_int/2 - (edge_margin + g_dash);
    
    
    sigma_deg = atand((x1+x2)/S_int); %degree
    sigma_deg_vec = [sigma_deg_vec sigma_deg];
    
    %minimum required DCN diameter if sigma = alpha
    Dm = (x1+x2)/(tan(angle));
    
    Dm = max([Dm, S_int]);
    Dm_vec = [Dm_vec Dm];
    
    %check if Dm satisfies zmax*cos(alpha) -> see plots

 %% Interleaving - vertical structure   
    
    
 %Limit of N at minimum Dm (and hence minimum N)
 
    %vertical separation between 2 ends of lenses
    %use CHi = Dm which is the relaxation that covers any extreme scenario
    HS_min = Dm * tand(6.3554);
    
    
    %min number of nodes can accomodate: rack and tower placed at Dm (min separation distance)
    %if sepatation between rack and tower increases (pushed further), then D increases from Dm 
    %HS increases, eventually N increases 
    min_Num_Nodes = floor((HS_min/Rack_Unit) + 3/4);
    min_Num_Nodes_vec = [min_Num_Nodes_vec min_Num_Nodes];
    
    %the real HS is smaller, since N is floored, so gamma should be
    %intrinsically smaller than 6.3554
    real_HS = (min_Num_Nodes - 3/4)*Rack_Unit;

 
    
    %and max diagnoal path needs to be less than zmax
    LAMBDA = Patch_Width_int - (edge_margin+g_dash) + ((Rack_Width - Patch_Width_int)/2)  - (edge_margin + G_loosen/2);
    XI = sqrt(LAMBDA^2 + Dm^2);
    Zpath = sqrt(XI^2 + real_HS^2);
    Zpath_vec = [Zpath_vec Zpath];
 
    %check if Zpath satisfy Zpath < zmax -> see plots
    
    
    
    %If D is pushed further (i.e. from Dm to maximum value Dx), then Chi maximised so N is also maximised
    %maximise D but Z < zmax
    
    %to solve the optimistation, sweep across from Dm to zmax to find Dx
    if Dm < zmax
        Dvec = linspace(Dm, zmax, 100);
        Dx = 0;
        Nx = 0;
        
        for dd = 1:1:length(Dvec)
            D  = Dvec(dd);
            CHI = D; 
            HS = CHI * tand(6.3554);
            N = floor((HS/Rack_Unit) + 3/4);
            real_HS = (N - 3/4)*Rack_Unit;
            
            LAMBDA = Patch_Width_int - (edge_margin+g_dash) + ((Rack_Width - Patch_Width_int)/2)  - (edge_margin + G_loosen/2);
            criteria = LAMBDA^2 + D^2 + real_HS^2;
            
            %if exceed zmax then use previous D as maximum value
            if criteria > (zmax^2)
                %Dx = Dvec(dd-1);
                break;
            %if not exceed then continue searching, assume current is the largest  
            else
                Dx =  Dvec(dd);
                Nx = N;
            end
            
        end
        

    %intrinsically not applicable    
    else
        
        Dx = -1;
        Nx = -1;
    end
        
    
    %Maximum separation distance (D) to ensure diagonal path < zmax
    Dx_vec = [Dx_vec Dx];
    Nx_vec = [Nx_vec, Nx];
 
    
 
    
end

%%

figure;
subplot(2,1,1);
plot(rad2deg(alpha), Np_floor_vec, 'LineWidth',1)
%xlabel('Maximum (half) actuator angle (deg)', 'FontSize', 14)
ylabel('Np')
legend('r = 7.45mm, L = 33.5mm')
subtitle('Maximum lenses (Np) horizontally within 1 Node in 19inch width', 'FontSize', 14)
grid on 

subplot(2,1,2); 
plot(rad2deg(alpha), X_vec, 'LineWidth',1)
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('X', 'FontSize', 14)
legend('r = 7.45mm, L = 33.5mm')
subtitle('Maximum transceiver pairs (X) within 1 Node  in 19inch width' ,'FontSize', 14)
grid on 



%%




figure;
subplot(2,1,1);
plot(rad2deg(alpha), Patch_Width_int_vec, 'LineWidth',1)
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('meter', 'FontSize', 14)
legend('r = 7.45mm, L = 33.5mm')
subtitle('Width (Wp) of an interleaving structure patch panel (under a given alpha and correspondingly X)', 'FontSize', 14)
grid on 

subplot(2,1,2); 
plot(rad2deg(alpha), S_int_vec,'LineWidth',1)
hold on 
plot(rad2deg(alpha), z_req_vec,'LineWidth',1)
hold off
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('meter', 'FontSize', 14)
legend('S', 'zmaxcos(alpha)')
subtitle('Separation distance (S) if racks and patch panel are closely spaced','FontSize', 14)
grid on 


%%



figure;
subplot(2,1,1);
plot(rad2deg(alpha), sigma_deg_vec, 'LineWidth',1)
hold on
plot(rad2deg(alpha), rad2deg(alpha), 'LineWidth',1)
hold off
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('deg', 'FontSize', 14)
legend('sigma', 'alpha')
subtitle('Maximum moving angle (sigma) at separation = S', 'FontSize', 14)
grid on 



subplot(2,1,2); 
plot(rad2deg(alpha), Dm_vec,'LineWidth',1)
hold on
plot(rad2deg(alpha), z_req_vec,'LineWidth',1)
hold off
xlabel('alpha: Maximum (half) actuator angle (deg)', 'FontSize', 14)
ylabel('meter', 'FontSize', 14)
legend('Dm', 'zmax*cos(alpha)')
subtitle('Min separation distance (Dm) to fulfil angular restriction (sigma <= alpha), zmax = 6.15 at 1550nm','FontSize', 14)
grid on 






%%



figure;
subplot(2,1,1);
plot(rad2deg(alpha), min_Num_Nodes_vec, 'LineWidth',1)
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('Number of nodes', 'FontSize', 14)
subtitle('Number of nodes (N) can accomodate when D = Dm', 'FontSize', 14)
grid on 

subplot(2,1,2); 
plot(rad2deg(alpha), Zpath_vec, 'LineWidth',1)
hold on
plot(rad2deg(alpha), zmax*ones(length(alpha), 1), 'LineWidth',1)
legend('diagonal path', '1550nm, zmax = 6.15m')
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('Zdiag(meters)', 'FontSize', 14)
subtitle('Zdiag when D = Dm and N = Nmin', 'FontSize', 14)
grid on 


%%

figure;
subplot(2,1,1);
plot(rad2deg(alpha), Dx_vec, 'LineWidth',1)
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('meters', 'FontSize', 14)
subtitle('Maximum separation distance (Dx) allowed to satisfy both vertical constraints', 'FontSize', 14)
grid on 


subplot(2,1,2);
plot(rad2deg(alpha), Nx_vec, 'LineWidth',1)
xlabel('alpha: Maximum required actuator angle on 1 side (deg)', 'FontSize', 14)
ylabel('number of nodes', 'FontSize', 14)
subtitle('Maximum number of nodes when D = Dx', 'FontSize', 14)
grid on 










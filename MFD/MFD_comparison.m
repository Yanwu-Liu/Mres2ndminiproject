close all
clear all
clc

%% 
% Place SMF_MFD.mat under same directory

% This file contains 3 sections:
% 1. Sweep and find an optimum g for Marcus graded index approximation to
% emulate 10.4um MFD at 1550nm as much as possible
%
% 2. Compare between 4 MFD approximation methods: 1 modes solver, 3
% empirical  formulae
%
% 3. Plot zmax for 2 apprimxation methods (they are most accurate): (1) Marcus
% graded index approximation (2) mode solver approximation

% The rest of analysis in the report will use mode solver approximation




%% 1. Find optimum g for Marcus graded index approximation


%This approximation is for graded index fibre
%find an optimal g to make MFD @ 1550nm as close to 10.4um as much as
%possible
focal =  18.36 * 10^(-3)
core_diameter = 8.2*1e-6
core_radius = core_diameter/2
NA = 0.14
wavelength = 1550*1e-9
V_1550  = 2*pi*core_radius*NA/wavelength


MFD_Marcuse_gsweep_vec  = [];
g_vec = 1:0.001:2;

for gg = 1:1:length(g_vec)
    g = g_vec(gg);
    A = ( 0.4 *( 1 + 4*(2/g)^(5/6) ))^(1/2);
    B = exp(0.298/g) - 1 + 1.478*(1 - exp(-0.077*g));
    C = 3.76 + exp(4.19/g^(0.418));

    MFD_Marcuse_gsweep = 2*core_radius*(  A/(V_1550 ^(2/(g+2))) + B/(V_1550 ^(3/2)) + C/(V_1550^(6)));
    MFD_Marcuse_gsweep_vec  = [MFD_Marcuse_gsweep_vec  MFD_Marcuse_gsweep];
end

figure;
plot(g_vec, MFD_Marcuse_gsweep_vec*1e6, 'LineWidth',1.0)
xlabel('g (exponent of the power law)', 'FontSize', 14)
ylabel('MFD Approximation (um)', 'FontSize', 14)
title('MFD Graded index approximation (Marcuse 1977) at 1550nm against different g values ', 'FontSize', 14)
grid on






%% 2. Compare between 4 methods of approximation


%% Mode solver approximation

%MFD_mode_solver_struct = load('/Volumes/YanwuLiu/MresSecondproject/simulation/July30/MFD/MFD_mode_solver/SMF_MFD.mat')
MFD_mode_solver_struct = load('SMF_MFD.mat')

wavelength_mode_solver = MFD_mode_solver_struct.lambda(1, :)*1e-09; 
MFD_mode_solver =  MFD_mode_solver_struct.lambda(2, :)*1e-06; 
zmax_mode_solver_vec = [];

for wm = 1:1:length(wavelength_mode_solver)
    
    wavelength_ms = wavelength_mode_solver(wm);
    MFD_ms = MFD_mode_solver(wm);
    zmax_mode_solver = 4*focal^2*wavelength_ms/(pi*MFD_ms^2);
    zmax_mode_solver_vec = [zmax_mode_solver_vec zmax_mode_solver];

end


%% Formula approximation

g_opt = 1.649
wavelength_range = (1460:1:1650)*1e-9

core_diameter = 8.2*1e-6
core_radius = core_diameter/2
NA = 0.14

MFD_Gauss_Newton_vec = [];
MFD_Marcuse_vec = [];
MFD_g_opt_vec = [];


V_vec  = [];

zmax_gopt_vec = [];

for ww = 1:1:length(wavelength_range)
    
    wavelength = wavelength_range(ww);
    V  = 2*pi*core_radius*NA/wavelength;
    V_vec  = [V_vec V];
    
    MFD_Gauss_Newton = 2*core_radius*(  172.04*exp( -  (V + 3.412)^2 / (2.141^2)   ) + 1   );
    MFD_Gauss_Newton_vec = [MFD_Gauss_Newton_vec MFD_Gauss_Newton];

    MFD_Marcuse = 2*core_radius*(0.65 + 1.619/V^(3/2) + 2.879/V^(6));
    %MFD_Marcuse = 2*core_radius*(sqrt(2/V) + 0.23/V^(3/2) + 18.01/V^(6));
    MFD_Marcuse_vec = [MFD_Marcuse_vec MFD_Marcuse];
    
    MFD_g_opt = MFD_Marcuse_optimal_g(V, g_opt, core_radius)
    MFD_g_opt_vec = [MFD_g_opt_vec MFD_g_opt];
    
    

    %maximum distance to maintain collimation
    zmax_gopt = 4*focal^2*wavelength/(pi*MFD_g_opt^2);
    zmax_gopt_vec = [zmax_gopt_vec zmax_gopt];

    
end


figure;
plot(wavelength_range*1e9, MFD_g_opt_vec*1e6 , '-.','LineWidth',1.5)
hold on
plot(wavelength_mode_solver*1e9, MFD_mode_solver*1e6, '-','LineWidth',1.5)
hold on
plot(wavelength_range*1e9, MFD_Gauss_Newton_vec*1e6, ':', 'LineWidth',1.5)
hold on
plot(wavelength_range*1e9, MFD_Marcuse_vec*1e6 , '--', 'LineWidth',1.5)
hold off
xlabel('wavelength (nm)', 'FontSize', 16)
ylabel('Approximated MFD(um)', 'FontSize', 16)
title('MFD approximation with different methods', 'FontSize', 16)
legend('Marcus g-opt Approx', 'Mode solver Approx','Gauss-Newton Approx', 'Marcuse Approx', 'FontSize', 16)
grid on


%% 3. Plot zmax for mode solver approximation and Marcus graded index g-opt approximation




figure;
plot(wavelength_range*1e9, zmax_gopt_vec, '-.','LineWidth',1.0)
hold on
plot(wavelength_mode_solver*1e9, zmax_mode_solver_vec,'-', 'LineWidth',1.0)
hold off
xlabel('wavelength (nm)', 'FontSize', 14)
ylabel('zmax(meters)', 'FontSize', 14)
legend('Marcus g-opt Approx', 'Mode solver Approx','FontSize', 14)
title('Maximum propagation distance zmax to maintain collimation (MFD approximated by Marcuse graded index g = 1.649)', 'FontSize', 14)
grid on









%%

function MFD_g_opt = MFD_Marcuse_optimal_g(V, g, core_radius)

    
    %A = ( 0.4 *( 1 + 4*(2/g)^(5/6) ))^(1/2);
    %B = exp(0.298/g) - 1 + 1.478*(1 - exp(-0.077*g));
    %C = 3.76 + exp(4.19/g^(0.418));

    %MFD_g_opt = 2*core_radius*(   A/(V^(2/(g+2))) + B/V^(3/2) + C/V^(6));
    
    A = ( 0.4 *( 1 + 4*(2/g)^(5/6) ))^(1/2);
    B = exp(0.298/g) - 1 + 1.478*(1 - exp(-0.077*g));
    C = 3.76 + exp(4.19/g^(0.418));

    MFD_g_opt = 2*core_radius*(  A/(V^(2/(g+2))) + B/(V^(3/2)) + C/(V^(6)));
    
   
end





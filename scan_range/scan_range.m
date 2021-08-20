
close all
clear all
clc

% A rough estimation of tip movements of tube (ignore radius size), for required actuator angle
% horizontal: 3.0360, 3.1243, 3.3309 for 1465nm, '1550nm, 1648nm, respectively
% vertical: gamma = 6.3554 deg for all wavelengths


%tube length
tube_length = [10, 20, 35, 50.8, 55, 60]*10^(-3);


%% vertical scan range

gamma_deg = 6.3554;
vertical_scanrange = 2*tube_length*sind(gamma_deg);


figure;
subplot(2,1,1);
plot(tube_length*10^3, vertical_scanrange*10^3, '-d', 'Color', [0.4940, 0.1840, 0.5560], 'LineWidth',1)
xlabel('Tube length (mm)', 'FontSize', 14)
ylabel('Vertical scan range (mm)', 'FontSize', 14)
legend('same for all wavelengths', 'FontSize', 14)
title('Vertical scan range (double sides)', 'FontSize', 14)
grid on 


%% horizontal scan range
alpha_deg_vec = [3.0360, 3.1243, 3.3309];
marker_vec = ['*', 'o', '+'];
%figure;
subplot(2,1,2);
for aa  = 1:1: length(alpha_deg_vec)
    
    alpha_deg = alpha_deg_vec(aa);
    horizontal_scanrange = 2*tube_length*sind(alpha_deg);
    plot(tube_length*10^3, horizontal_scanrange*10^3, '-', 'Marker', marker_vec(aa), 'LineWidth',1)
    hold on
    
end
hold off
xlabel('Tube length (mm)', 'FontSize', 14)
ylabel('Horizontal scan range (mm)', 'FontSize', 14)
grid on 
legend('1465nm', '1550nm', '1648nm', 'FontSize', 14)
title('Horizontal scan range (double sides)', 'FontSize', 14)




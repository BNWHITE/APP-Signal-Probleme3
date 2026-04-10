%% ========================================================================
%  SIMULATION_QUANTIFICATION.m - Simulation de la quantification
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

fprintf('=== Simulation de la quantification ===\n\n');

%% Paramètres
Fe = 44100;         % Hz
f0 = 1000;          % Fréquence du signal test (Hz)
V_max = 0.5;        % Amplitude crête (V)
A = 2 * V_max;      % Dynamique totale
duree = 0.1;        % Durée du signal (s)
bits_range = 1:20;  % Nombre de bits à tester

%% Génération du signal test
t = 0:1/Fe:(duree - 1/Fe);
N = length(t);

% Signal sinusoïdal
x = V_max * sin(2*pi*f0*t);

fprintf('Signal test : sinusoïde %.0f Hz, amplitude %.1f V, Fe = %d Hz\n', f0, V_max, Fe);
fprintf('Durée = %.3f s, N = %d échantillons\n\n', duree, N);

%% Quantification pour différents nombres de bits
SNR_mesure = zeros(1, length(bits_range));
SNR_theorie = zeros(1, length(bits_range));
debit = zeros(1, length(bits_range));

for idx = 1:length(bits_range)
    b = bits_range(idx);
    
    % Quantification
    x_q = round(x * 2^(b-1)) / 2^(b-1);
    
    % Erreur de quantification
    e = x - x_q;
    
    % Puissances
    P_signal = mean(x.^2);
    P_erreur = mean(e.^2);
    
    % SNR mesuré
    if P_erreur > 0
        SNR_mesure(idx) = 10*log10(P_signal / P_erreur);
    else
        SNR_mesure(idx) = Inf;
    end
    
    % SNR théorique
    q = A / (2^b);
    Pe_theorie = q^2 / 12;
    SNR_theorie(idx) = 10*log10(P_signal / Pe_theorie);
    
    % Débit
    debit(idx) = Fe * b * 2;  % stéréo
end

%% Affichage
figure('Name', 'Simulation de la quantification', 'Position', [100, 100, 1400, 900], 'Color', 'w');

% 1. SNR en fonction du nombre de bits
subplot(2,3,1);
plot(bits_range, SNR_mesure, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
plot(bits_range, SNR_theorie, 'r--', 'LineWidth', 1.5);
yline(90, 'g--', 'Cible 90 dB', 'LineWidth', 1.5);
xlabel('Nombre de bits (b)'); ylabel('SNR (dB)');
title('SNR vs nombre de bits');
legend('Mesuré', 'Théorique', 'Location', 'southeast');
grid on;

% 2. SNR en fonction du débit
subplot(2,3,2);
plot(debit/1000, SNR_mesure, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
yline(90, 'g--', 'Cible 90 dB', 'LineWidth', 1.5);
xlabel('Débit (kbits/s)'); ylabel('SNR (dB)');
title('SNR vs débit (stéréo)');
grid on;

% 3. Signal quantifié pour différents bits
b_examples = [4, 8, 12, 16];
t_plot = t(1:min(200, N));  % Premiers échantillons

for i = 1:length(b_examples)
    subplot(2, length(b_examples), length(b_examples) + i);
    b_ex = b_examples(i);
    x_q_ex = round(x(1:length(t_plot)) * 2^(b_ex-1)) / 2^(b_ex-1);
    e_ex = x(1:length(t_plot)) - x_q_ex;
    
    yyaxis left;
    plot(t_plot*1000, x(1:length(t_plot)), 'b-', 'LineWidth', 0.5);
    hold on;
    plot(t_plot*1000, x_q_ex, 'r-', 'LineWidth', 1);
    ylabel('Amplitude (V)');
    
    yyaxis right;
    plot(t_plot*1000, e_ex, 'g-', 'LineWidth', 0.5);
    ylabel('Erreur (V)');
    
    xlabel('Temps (ms)');
    title(sprintf('b = %d bits, SNR = %.1f dB', b_ex, ...
        10*log10(mean(x(1:length(t_plot)).^2) / max(mean(e_ex.^2), eps))));
    grid on;
    legend('Original', 'Quantifié', 'Erreur', 'Location', 'best', 'FontSize', 6);
end

sgtitle('Simulation de la quantification - Problème III', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, '../figures/simulation_quantification.png');

%% Affichage des résultats numériques
fprintf('--- Résultats ---\n');
fprintf('  b (bits) | SNR mesuré (dB) | SNR théorique (dB) | Débit stéréo (kbits/s)\n');
fprintf('  ---------|-----------------|--------------------|-----------------------\n');
for idx = 1:length(bits_range)
    b = bits_range(idx);
    fprintf('  %8d | %15.2f | %18.2f | %21.2f\n', ...
        b, SNR_mesure(idx), SNR_theorie(idx), debit(idx)/1000);
end

% Trouver le nombre de bits minimum pour 90 dB
b_min = find(SNR_mesure >= 90, 1);
if ~isempty(b_min)
    fprintf('\n  → Nombre de bits minimum pour SNR >= 90 dB : %d bits\n', bits_range(b_min));
    fprintf('    Débit stéréo correspondant : %.2f kbits/s\n', debit(b_min)/1000);
end

fprintf('\nFigure sauvegardée : ../figures/simulation_quantification.png\n');

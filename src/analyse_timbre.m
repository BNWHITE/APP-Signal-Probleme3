%% ========================================================================
%  ANALYSE_TIMBRE.m - Analyse du timbre des instruments
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

fprintf('=== Analyse du timbre et des harmoniques ===\n\n');

%% Paramètres de numérisation
Fe = 44100;     % Hz
b = 16;         % bits
f_max = Fe/2;   % Fréquence max capturable

%% Simulation : spectre d'un instrument
% On simule un signal avec fondamentale + harmoniques
% (comme un instrument réel)

f0 = 440;       % La4 (diapason)
duree = 1;      % seconde
t = 0:1/Fe:(duree - 1/Fe);
N = length(t);

% Simulation de différents timbres
fprintf('--- Simulation du timbre pour f0 = %.0f Hz (La4) ---\n\n');

% Nombre max d'harmoniques capturable
n_harm_max = floor(f_max / f0);
fprintf('  Nombre max d''harmoniques dans [0, Fe/2] = floor(%.0f / %.0f) = %d\n', ...
    f_max, f0, n_harm_max);

% 1. "Flûte" : fondamentale dominante + peu d'harmoniques
ampli_flute = [1, 0.3, 0.1, 0.02];
x_flute = zeros(size(t));
for k = 1:length(ampli_flute)
    x_flute = x_flute + ampli_flute(k) * sin(2*pi*k*f0*t);
end

% 2. "Violon" : riche en harmoniques
n_harm_violon = min(20, n_harm_max);
ampli_violon = 1 ./ (1:n_harm_violon);  % décroissance en 1/k
x_violon = zeros(size(t));
for k = 1:n_harm_violon
    x_violon = x_violon + ampli_violon(k) * sin(2*pi*k*f0*t);
end

% 3. "Piano" : harmoniques avec légère inarmonicité
n_harm_piano = min(15, n_harm_max);
ampli_piano = exp(-(0:n_harm_piano-1)/5);  % décroissance exponentielle
x_piano = zeros(size(t));
for k = 1:n_harm_piano
    % Légère inarmonicité du piano
    fk = k * f0 * sqrt(1 + 0.0001 * k^2);
    if fk < f_max
        x_piano = x_piano + ampli_piano(k) * sin(2*pi*fk*t);
    end
end

% Normalisation
x_flute = x_flute / max(abs(x_flute));
x_violon = x_violon / max(abs(x_violon));
x_piano = x_piano / max(abs(x_piano));

%% Affichage temporel et spectral
figure('Name', 'Analyse du timbre', 'Position', [50, 50, 1400, 900], 'Color', 'w');

signaux = {x_flute, x_violon, x_piano};
noms = {'Flûte (simulée)', 'Violon (simulé)', 'Piano (simulé)'};
couleurs = {'b', 'r', [0.2 0.7 0.2]};

M = 2^16;  % Résolution FFT fine
f_fft = (0:M-1) * Fe / M;

for i = 1:3
    x = signaux{i};
    
    % Temporel (2 périodes)
    subplot(3, 3, (i-1)*3 + 1);
    n_ech = round(2/f0 * Fe);
    plot(t(1:n_ech)*1000, x(1:n_ech), 'Color', couleurs{i}, 'LineWidth', 1.2);
    xlabel('Temps (ms)'); ylabel('Amplitude');
    title(sprintf('%s - Temporel', noms{i}));
    grid on;
    
    % Spectre (FFT)
    X = abs(fft(x, M)) / N;
    X = X(1:M/2+1);
    X(2:end-1) = 2*X(2:end-1);
    f_plot = f_fft(1:M/2+1);
    
    subplot(3, 3, (i-1)*3 + 2);
    plot(f_plot/1000, X, 'Color', couleurs{i}, 'LineWidth', 1);
    xlabel('Fréquence (kHz)'); ylabel('Amplitude');
    title(sprintf('%s - Spectre', noms{i}));
    grid on; xlim([0, 10]);
    
    % Spectre en dB
    subplot(3, 3, (i-1)*3 + 3);
    X_dB = 20*log10(X / max(X) + eps);
    plot(f_plot/1000, X_dB, 'Color', couleurs{i}, 'LineWidth', 1);
    xlabel('Fréquence (kHz)'); ylabel('Amplitude (dB)');
    title(sprintf('%s - Spectre (dB)', noms{i}));
    grid on; xlim([0, f_max/1000]); ylim([-100, 5]);
    hold on;
    xline(f_max/1000, 'k--', 'Fe/2', 'LineWidth', 1);
end

sgtitle(sprintf('Analyse du timbre - f0 = %.0f Hz, Fe = %d Hz', f0, Fe), ...
    'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, '../figures/analyse_timbre.png');

%% Analyse quantitative
fprintf('--- Analyse des harmoniques ---\n\n');
for i = 1:3
    x = signaux{i};
    X = abs(fft(x, M)) / N;
    X = X(1:M/2+1);
    X(2:end-1) = 2*X(2:end-1);
    
    P_totale = sum(X.^2);
    
    fprintf('  %s :\n', noms{i});
    
    % Trouver les harmoniques
    for k = 1:min(10, n_harm_max)
        fk = k * f0;
        [~, idx] = min(abs(f_fft(1:M/2+1) - fk));
        amp_k = X(idx);
        P_k = amp_k^2 / P_totale * 100;
        if P_k > 0.01
            fprintf('    Harmonique %2d (f = %6.0f Hz) : amplitude = %.4f, puissance = %.2f%%\n', ...
                k, fk, amp_k, P_k);
        end
    end
    
    % Fréquence max significative
    idx_99 = find(cumsum(X.^2) / P_totale >= 0.9999, 1);
    f_99 = f_fft(idx_99);
    fprintf('    Fréquence contenant 99.99%% de la puissance : %.0f Hz\n', f_99);
    fprintf('    Capturé avec Fe = %d Hz ? %s\n\n', Fe, string(f_99 <= f_max));
end

fprintf('\n  → Avec Fe = %d Hz (Fe/2 = %d Hz), le timbre est préservé\n', Fe, Fe/2);
fprintf('    pour tous les instruments simulés.\n');
fprintf('\nFigure sauvegardée : ../figures/analyse_timbre.png\n');

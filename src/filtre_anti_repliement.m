%% ========================================================================
%  FILTRE_ANTI_REPLIEMENT.m - Conception du filtre anti-repliement
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

fprintf('=== Conception du filtre anti-repliement ===\n\n');

%% Paramètres
Fe = 44100;        % Fréquence d'échantillonnage (Hz)
f_max = 20000;     % Fréquence max du signal utile (Hz)
SNR_cible = 90;    % dB

%% Gabarit du filtre
% Le filtre anti-repliement doit :
% 1. Laisser passer la bande [0, f_max] = [0, 20 kHz]
% 2. Atténuer les fréquences au-delà de Fe/2 = 22.05 kHz
% 3. L'atténuation doit être >= SNR_cible pour éviter le repliement

f_pass = f_max;         % Fréquence de coupure (fin bande passante)
f_stop = Fe/2;           % Début de la bande atténuée
delta_f = f_stop - f_pass;  % Bande de transition

% Ondulation en bande passante : on choisit Apass faible
Apass = 0.1;       % dB (ondulation max en bande passante)
Astop = SNR_cible;  % dB (atténuation en bande atténuée)

% Conversion en delta
delta1 = 10^(Apass/20) - 1;    % erreur bande passante
delta2 = 10^(-Astop/20);       % erreur bande atténuée

fprintf('--- Gabarit du filtre ---\n');
fprintf('  Type             : Passe-bas\n');
fprintf('  Fe               : %d Hz\n', Fe);
fprintf('  Fpass (fc)       : %d Hz\n', f_pass);
fprintf('  Fstop (fa)       : %.0f Hz\n', f_stop);
fprintf('  Bande transition : Δf = %.0f Hz\n', delta_f);
fprintf('  Apass            : %.1f dB (ondulation BP)\n', Apass);
fprintf('  Astop            : %d dB (atténuation BA)\n', Astop);
fprintf('  δ1               : %.6f\n', delta1);
fprintf('  δ2               : %.6e\n', delta2);

%% Conception avec différentes méthodes
fprintf('\n--- Conception du filtre ---\n');

% Normalisation des fréquences (entre 0 et 1, avec 1 = Fe/2)
Wpass = f_pass / (Fe/2);   % fréquence passante normalisée
Wstop = f_stop / (Fe/2);   % fréquence d'arrêt normalisée

fprintf('  Fréquences normalisées : Wpass = %.4f, Wstop = %.4f\n', Wpass, Wstop);

% Méthode 1 : Estimation de l'ordre par la formule de Kaiser
% N ≈ (-20*log10(sqrt(delta1*delta2)) - 13) / (14.6 * delta_f / Fe)
N_kaiser = ceil((-20*log10(sqrt(delta1*delta2)) - 13) / (14.6 * delta_f / Fe));
fprintf('\n  Estimation de l''ordre (formule de Kaiser) :\n');
fprintf('    N ≈ %d\n', N_kaiser);

% Méthode 2 : Utilisation de firpmord (si disponible)
try
    [N_pm, fo, ao, w] = firpmord([f_pass, f_stop], [1, 0], [delta1, delta2], Fe);
    fprintf('\n  Estimation de l''ordre (firpmord) :\n');
    fprintf('    N = %d\n', N_pm);
    
    % Synthèse du filtre equiripple (Parks-McClellan)
    h = firpm(N_pm, fo, ao, w);
    fprintf('    Filtre synthétisé avec %d coefficients\n', length(h));
catch
    fprintf('\n  firpmord non disponible, utilisation de fir1\n');
    N_pm = N_kaiser;
    % Filtre par fenêtre (méthode plus simple)
    h = fir1(N_pm, Wpass);
    fprintf('    Filtre FIR fenêtré avec %d coefficients\n', length(h));
end

%% Affichage de la réponse en fréquence
figure('Name', 'Filtre anti-repliement', 'Position', [100, 100, 1200, 800], 'Color', 'w');

% Calcul de la réponse en fréquence
M = 2^14;  % nombre de points FFT
[H, f] = freqz(h, 1, M, Fe);

% Amplitude en dB
subplot(2,2,1);
plot(f/1000, 20*log10(abs(H)), 'b', 'LineWidth', 1.5);
hold on;
xline(f_pass/1000, 'r--', 'fc = 20 kHz', 'LineWidth', 1);
xline(f_stop/1000, 'g--', 'Fe/2 = 22.05 kHz', 'LineWidth', 1);
yline(-Astop, 'k--', sprintf('-%d dB', Astop), 'LineWidth', 1);
xlabel('Fréquence (kHz)'); ylabel('|H(f)| (dB)');
title('Réponse en fréquence (dB)');
grid on; xlim([0, Fe/2/1000]);
ylim([-120, 5]);

% Amplitude linéaire
subplot(2,2,2);
plot(f/1000, abs(H), 'b', 'LineWidth', 1.5);
hold on;
xline(f_pass/1000, 'r--', 'fc', 'LineWidth', 1);
xline(f_stop/1000, 'g--', 'Fe/2', 'LineWidth', 1);
xlabel('Fréquence (kHz)'); ylabel('|H(f)|');
title('Réponse en fréquence (linéaire)');
grid on; xlim([0, Fe/2/1000]);

% Zoom bande passante
subplot(2,2,3);
plot(f/1000, 20*log10(abs(H)), 'b', 'LineWidth', 1.5);
hold on;
yline(0, 'k-');
yline(-Apass, 'r--', sprintf('-%.1f dB', Apass), 'LineWidth', 1);
yline(Apass, 'r--', sprintf('+%.1f dB', Apass), 'LineWidth', 1);
xlabel('Fréquence (kHz)'); ylabel('|H(f)| (dB)');
title('Zoom bande passante');
grid on; xlim([0, f_pass*1.1/1000]);
ylim([-1, 1]);

% Réponse impulsionnelle
subplot(2,2,4);
stem(0:length(h)-1, h, 'b', 'MarkerSize', 2);
xlabel('n'); ylabel('h(n)');
title(sprintf('Réponse impulsionnelle (N = %d)', length(h)));
grid on;

sgtitle(sprintf('Filtre anti-repliement passe-bas - Ordre %d', length(h)-1), ...
        'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, '../figures/filtre_anti_repliement.png');
fprintf('\nFigure sauvegardée : ../figures/filtre_anti_repliement.png\n');

%% Vérification des performances
fprintf('\n--- Vérification des performances ---\n');

% Atténuation à Fe/2
idx_fe2 = find(f >= Fe/2, 1);
if ~isempty(idx_fe2)
    att_fe2 = -20*log10(abs(H(idx_fe2)));
    fprintf('  Atténuation à Fe/2 = %.1f dB (cible >= %d dB)\n', att_fe2, Astop);
end

% Ondulation en bande passante
idx_bp = f <= f_pass;
ondulation_bp = max(abs(20*log10(abs(H(idx_bp)))));
fprintf('  Ondulation en BP = %.4f dB (cible <= %.1f dB)\n', ondulation_bp, Apass);

% Fréquence de coupure à -3 dB
idx_3dB = find(20*log10(abs(H)) <= -3, 1);
if ~isempty(idx_3dB)
    f_3dB = f(idx_3dB);
    fprintf('  Fréquence de coupure à -3 dB = %.0f Hz\n', f_3dB);
end

fprintf('\n  Nombre de coefficients du filtre : %d\n', length(h));
fprintf('  Nombre de multiplications par échantillon : %d\n', length(h));
fprintf('  → Sur un microcontrôleur, cela correspond à %d MAC/s\n', length(h) * Fe);

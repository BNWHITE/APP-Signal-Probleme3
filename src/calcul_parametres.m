%% ========================================================================
%  CALCUL_PARAMETRES.m - Calcul détaillé de tous les paramètres
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

fprintf('=== Calcul des paramètres de numérisation ===\n\n');

%% Données du problème
f_min = 20;            % Hz
f_max = 20000;         % Hz
SNR_cible = 90;        % dB
V_max = 0.5;           % V (amplitude crête)
A = 2 * V_max;         % Dynamique totale = 1 V
P_moy = 30e-3;         % Puissance moyenne (W)

%% ---- FRÉQUENCE D'ÉCHANTILLONNAGE ----
fprintf('--- Fréquence d''échantillonnage ---\n');

% Shannon : Fe >= 2 * f_max = 40 000 Hz
Fe_shannon = 2 * f_max;
fprintf('  Théorème de Shannon : Fe >= 2 × f_max = 2 × %d = %d Hz\n', f_max, Fe_shannon);

% En pratique, on a besoin d'une bande de transition pour le filtre
% Le filtre anti-repliement doit couper avant Fe/2
% Si on prend Fe = 44100 Hz (standard CD), on a :
% - Bande passante : [0, 20000] Hz
% - Bande de transition : [20000, 22050] Hz (largeur = 2050 Hz)
% C'est suffisant pour un filtre d'ordre raisonnable

Fe_options = [40000, 44100, 48000, 96000];
fprintf('\n  Options de Fe :\n');
for i = 1:length(Fe_options)
    Fe_i = Fe_options(i);
    bande_trans = Fe_i/2 - f_max;
    fprintf('    Fe = %d Hz : Fe/2 = %d Hz, bande de transition = %d Hz', ...
            Fe_i, Fe_i/2, bande_trans);
    if Fe_i == 44100
        fprintf(' ← Standard CD\n');
    elseif Fe_i == 48000
        fprintf(' ← Standard studio\n');
    else
        fprintf('\n');
    end
end

Fe = 44100;  % Choix final
fprintf('\n  ★ Choix : Fe = %d Hz (standard CD, compatible)\n', Fe);

%% ---- NOMBRE DE BITS ----
fprintf('\n--- Nombre de bits de quantification ---\n');

% Méthode 1 : Approximation sinusoïdale
% SNR = 6.02b + 1.76 (sinus pleine échelle)
b_approx = ceil((SNR_cible - 1.76) / 6.02);
SNR_approx = 6.02 * b_approx + 1.76;
fprintf('  Méthode 1 (sinus pleine échelle) :\n');
fprintf('    SNR = 6.02×b + 1.76\n');
fprintf('    b >= (%.0f - 1.76) / 6.02 = %.2f → b = %d bits\n', ...
        SNR_cible, (SNR_cible - 1.76)/6.02, b_approx);
fprintf('    SNR obtenu = %.2f dB\n', SNR_approx);

% Méthode 2 : Calcul exact avec la puissance moyenne
% Pe = q²/12, q = A / 2^b
% SNR = Ps / Pe = P_moy / (q²/12) = 12 * P_moy * 2^(2b) / A²
% SNR_dB = 10*log10(12 * P_moy / A²) + 20*b*log10(2)
C = 10*log10(12 * P_moy / A^2);
b_exact = (SNR_cible - C) / (20*log10(2));
b_calcul = ceil(b_exact);

fprintf('\n  Méthode 2 (avec P_moy = %.0f mW) :\n', P_moy*1000);
fprintf('    SNR = 10×log10(12×P_moy/A²) + 6.02×b\n');
fprintf('    SNR = %.2f + 6.02×b\n', C);
fprintf('    b >= (%.0f - (%.2f)) / 6.02 = %.2f → b = %d bits\n', ...
        SNR_cible, C, b_exact, b_calcul);

% Vérification
q_final = A / (2^b_calcul);
Pe_final = q_final^2 / 12;
SNR_final = 10*log10(P_moy / Pe_final);
fprintf('    Vérification : SNR = %.2f dB ✓\n', SNR_final);

b = max(b_calcul, 16);  % Au minimum 16 bits (standard CD)
fprintf('\n  ★ Choix : b = %d bits\n', b);

%% ---- PAS DE QUANTIFICATION ----
fprintf('\n--- Pas de quantification ---\n');
q = A / (2^b);
N_niveaux = 2^b;
fprintf('  q = A / 2^b = %.3f / 2^%d = %.6e V = %.3f µV\n', A, b, q, q*1e6);
fprintf('  Nombre de niveaux = 2^%d = %d\n', b, N_niveaux);

%% ---- PUISSANCE DU BRUIT DE QUANTIFICATION ----
fprintf('\n--- Puissance du bruit de quantification ---\n');
Pe = q^2 / 12;
Pe_dBW = 10*log10(Pe);
fprintf('  Pe = q²/12 = %.6e W\n', Pe);
fprintf('  Pe = %.2f dBW\n', Pe_dBW);

%% ---- SNR FINAL ----
fprintf('\n--- SNR obtenu ---\n');
SNR = 10*log10(P_moy / Pe);
fprintf('  SNR = 10×log10(P_moy / Pe) = 10×log10(%.3e / %.3e)\n', P_moy, Pe);
fprintf('  SNR = %.2f dB\n', SNR);
fprintf('  Cible : %d dB → %s\n', SNR_cible, ...
    string(SNR >= SNR_cible));

%% ---- DÉBIT BINAIRE ----
fprintf('\n--- Débit binaire ---\n');
n_canaux = 2;  % Stéréo

D_mono = Fe * b;
D_stereo = D_mono * n_canaux;

fprintf('  Débit mono   = Fe × b = %d × %d = %d bits/s\n', Fe, b, D_mono);
fprintf('                = %.2f kbits/s\n', D_mono/1000);
fprintf('  Débit stéréo = %d × %d = %d bits/s\n', D_mono, n_canaux, D_stereo);
fprintf('                = %.2f kbits/s = %.4f Mbits/s\n', ...
        D_stereo/1000, D_stereo/1e6);

%% ---- STOCKAGE ----
fprintf('\n--- Capacité de stockage (1 heure stéréo) ---\n');
duree = 3600; % secondes

volume_bits = D_stereo * duree;
volume_octets = volume_bits / 8;
volume_Ko = volume_octets / 1024;
volume_Mo = volume_Ko / 1024;
volume_Go = volume_Mo / 1024;

fprintf('  Volume = %.2e bits = %.2e octets\n', volume_bits, volume_octets);
fprintf('  Volume = %.2f Ko = %.2f Mo = %.4f Go\n', volume_Ko, volume_Mo, volume_Go);

% Comparaison avec la capacité d'un CD (700 Mo)
capacite_cd_Mo = 700;
fprintf('\n  Capacité CD = %d Mo\n', capacite_cd_Mo);
if volume_Mo <= capacite_cd_Mo
    fprintf('  → %.2f Mo < %d Mo : stockage sur CD possible ✓\n', volume_Mo, capacite_cd_Mo);
else
    fprintf('  → %.2f Mo > %d Mo : stockage sur CD IMPOSSIBLE ✗\n', volume_Mo, capacite_cd_Mo);
end

% Durée max sur un CD
duree_max_cd = capacite_cd_Mo * 1024^2 * 8 / D_stereo;
fprintf('  Durée max sur CD = %.1f min\n', duree_max_cd/60);

%% ---- TABLEAU RÉCAPITULATIF ----
fprintf('\n=============================================\n');
fprintf('  TABLEAU RÉCAPITULATIF\n');
fprintf('=============================================\n');
fprintf('  Paramètre                   | Valeur\n');
fprintf('  ----------------------------|------------------\n');
fprintf('  Bande audio                 | [%d Hz, %d Hz]\n', f_min, f_max);
fprintf('  Fréq. échantillonnage (Fe)  | %d Hz\n', Fe);
fprintf('  Nombre de bits (b)          | %d bits\n', b);
fprintf('  Pas de quantification (q)   | %.3f µV\n', q*1e6);
fprintf('  Niveaux de quantification   | %d\n', N_niveaux);
fprintf('  SNR de quantification       | %.2f dB\n', SNR);
fprintf('  Nombre de canaux            | %d (stéréo)\n', n_canaux);
fprintf('  Débit binaire               | %.0f kbits/s\n', D_stereo/1000);
fprintf('  Stockage 1h stéréo          | %.2f Mo\n', volume_Mo);
fprintf('  Compatible CD               | %s\n', string(volume_Mo <= 700));
fprintf('=============================================\n');

%% ========================================================================
%  MAIN_PROBLEME3.m - Script principal : Résolution du Problème III
%  APP Signal - ISEP 2025-2026
%  
%  Problème : Enregistrement numérique haute fidélité
%  - Bande de fréquences : 20 Hz à 20 000 Hz
%  - SNR moyen : 90 dB
%  - Micro idéal, dynamique [-500 mV, +500 mV]
%  - Puissance moyenne en sortie : 30 mW
%  ========================================================================
clear; close all; clc;

fprintf('==========================================================\n');
fprintf('  PROBLÈME III : Numérisation d''un signal audio Hi-Fi\n');
fprintf('==========================================================\n\n');

%% ---- 1. PARAMÈTRES DU PROBLÈME ----
fprintf('--- 1. Paramètres du problème ---\n');

f_min = 20;           % Fréquence minimale (Hz)
f_max = 20000;        % Fréquence maximale (Hz)
SNR_cible = 90;       % Rapport signal à bruit cible (dB)
A = 1;                % Dynamique totale = 2*500mV = 1V => amplitude crête = 500 mV
V_max = 0.5;          % Tension crête (V)
P_moy = 30e-3;        % Puissance moyenne en sortie du micro (W)
R = 1;                % Impédance de référence (Ohm) - normalisée

fprintf('  Bande de fréquences : [%d Hz, %d Hz]\n', f_min, f_max);
fprintf('  SNR cible : %d dB\n', SNR_cible);
fprintf('  Dynamique du micro : [-%d mV, +%d mV]\n', V_max*1000, V_max*1000);
fprintf('  Puissance moyenne : %.0f mW\n', P_moy*1000);

%% ---- 2. SCHÉMA FONCTIONNEL DE NUMÉRISATION ----
fprintf('\n--- 2. Schéma fonctionnel de numérisation ---\n');
fprintf('  Micro --> Filtre anti-repliement --> Échantillonneur --> Quantificateur --> Signal numérique\n');
fprintf('           (passe-bas, fc < Fe/2)    (fréquence Fe)     (b bits)\n\n');

%% ---- 3. DÉTERMINATION DE LA FRÉQUENCE D''ÉCHANTILLONNAGE ----
fprintf('--- 3. Fréquence d''échantillonnage ---\n');

% Théorème de Shannon : Fe >= 2 * f_max
Fe_min_shannon = 2 * f_max;
fprintf('  Fréquence minimale (Shannon) : Fe >= 2 * %d = %d Hz\n', f_max, Fe_min_shannon);

% En pratique, on prend une marge pour le filtre anti-repliement
% Le filtre n'est pas idéal, il faut une bande de transition
% On choisit Fe avec une marge (typiquement 10% à 20%)
Fe_pratique = 44100;  % Standard CD : 44.1 kHz
Fe_min_pratique = 40000; % Minimum pratique avec marge pour le filtre

fprintf('  Fe choisie (standard CD) : %d Hz = %.1f kHz\n', Fe_pratique, Fe_pratique/1000);
fprintf('  Fe/2 = %d Hz > f_max = %d Hz --> Shannon respecté ✓\n', Fe_pratique/2, f_max);

% Marge pour le filtre anti-repliement
marge_filtre = Fe_pratique/2 - f_max;
fprintf('  Marge pour le filtre anti-repliement : %.0f Hz\n', marge_filtre);

%% ---- 4. DÉTERMINATION DU NOMBRE DE BITS ----
fprintf('\n--- 4. Nombre de bits de quantification ---\n');

% SNR de quantification pour un signal sinusoïdal pleine échelle :
% SNR(dB) = 6.02*b + 1.76
% Pour un signal quelconque, la formule dépend du facteur de crête
% SNR(dB) = 6.02*b + 1.76 + 20*log10(Vrms/Vmax)

% Calcul du nombre de bits minimum
% On utilise : SNR = 6.02*b + 1.76 (cas sinusoïdal pleine échelle)
b_min_sinus = ceil((SNR_cible - 1.76) / 6.02);
fprintf('  Formule : SNR = 6.02*b + 1.76 (sinus pleine échelle)\n');
fprintf('  b_min (sinus) = ceil((%d - 1.76) / 6.02) = %d bits\n', SNR_cible, b_min_sinus);

% Calcul plus rigoureux avec la puissance moyenne donnée
% P_moy = 30 mW sur R = 1 Ohm => Vrms = sqrt(P_moy * R)
% Mais le signal n'est pas forcément un sinus pleine échelle
% SNR_q = (3/2) * 2^(2b) * (Ps / Pmax) en linéaire
% Avec Pmax = (A/2)^2 = V_max^2 (puissance max crête)

% Approche générale :
% Pe (bruit de quant) = q^2/12, avec q = A/2^b = 2*V_max/2^b
% SNR = Ps/Pe = P_moy / (q^2/12)
% SNR(dB) = 10*log10(P_moy * 12 / q^2)

% On résout pour b :
% 10*log10(P_moy * 12 * 2^(2b) / (2*V_max)^2) >= 90
% 10*log10(P_moy * 12) + 20*b*log10(2) - 10*log10(A^2) >= 90

A_dyn = 2 * V_max;  % Dynamique totale = 1V
q_factor = 10*log10(12 * P_moy / A_dyn^2);
b_exact = (SNR_cible - q_factor) / (20*log10(2));
b_choisi = ceil(b_exact);

fprintf('\n  Calcul rigoureux avec P_moy = %d mW :\n', P_moy*1000);
fprintf('  q = A / 2^b = %.3f / 2^b\n', A_dyn);
fprintf('  Pe = q²/12 = (%.3f)² / (12 * 2^(2b))\n', A_dyn);
fprintf('  SNR = 10*log10(P_moy / Pe)\n');
fprintf('  SNR = 10*log10(12 * P_moy / A²) + 20*b*log10(2)\n');
fprintf('  SNR = %.2f + 6.02*b\n', q_factor);
fprintf('  b_min = ceil((%.0f - (%.2f)) / 6.02) = %d bits\n', SNR_cible, q_factor, b_choisi);

% Vérification
q = A_dyn / (2^b_choisi);
Pe = q^2 / 12;
SNR_obtenu = 10*log10(P_moy / Pe);
fprintf('\n  Vérification avec b = %d bits :\n', b_choisi);
fprintf('  Pas de quantification q = %.6e V\n', q);
fprintf('  Puissance bruit de quant. Pe = %.6e W\n', Pe);
fprintf('  SNR obtenu = %.2f dB (cible : %d dB) ✓\n', SNR_obtenu, SNR_cible);

% Standard CD = 16 bits
b_cd = 16;
SNR_cd = q_factor + 20*b_cd*log10(2);
fprintf('\n  Avec b = %d bits (standard CD) : SNR = %.2f dB\n', b_cd, SNR_cd);

%% ---- 5. FILTRE ANTI-REPLIEMENT ----
fprintf('\n--- 5. Filtre anti-repliement ---\n');

Fe = Fe_pratique;
f_coupure = f_max;          % Fréquence de coupure = 20 kHz
f_stop = Fe/2;               % Fréquence début bande atténuée

fprintf('  Type : Passe-bas\n');
fprintf('  Fréquence de coupure fc = %d Hz\n', f_coupure);
fprintf('  Fréquence début bande atténuée fa = %.0f Hz\n', f_stop);
fprintf('  Bande de transition : Δf = fa - fc = %.0f Hz\n', f_stop - f_coupure);
fprintf('  Atténuation en bande atténuée >= %d dB (= SNR cible)\n', SNR_cible);

%% ---- 6. CALCUL DU DÉBIT ----
fprintf('\n--- 6. Débit du signal numérique ---\n');

n_canaux = 2;  % Stéréo
b_final = max(b_choisi, b_cd);  % On prend au minimum 16 bits

debit_mono = Fe * b_final;          % bits/s par canal
debit_stereo = debit_mono * n_canaux;  % bits/s total

fprintf('  Fe = %d Hz, b = %d bits, canaux = %d (stéréo)\n', Fe, b_final, n_canaux);
fprintf('  Débit mono   = Fe × b = %d × %d = %.0f bits/s = %.2f kbits/s\n', ...
    Fe, b_final, debit_mono, debit_mono/1000);
fprintf('  Débit stéréo = %.0f bits/s = %.2f kbits/s = %.4f Mbits/s\n', ...
    debit_stereo, debit_stereo/1000, debit_stereo/1e6);

%% ---- 7. CAPACITÉ DE STOCKAGE ----
fprintf('\n--- 7. Capacité de stockage pour 1h de concert stéréo ---\n');

duree = 3600;  % 1 heure en secondes
stockage_bits = debit_stereo * duree;
stockage_octets = stockage_bits / 8;
stockage_Mo = stockage_octets / (1024^2);
stockage_Go = stockage_octets / (1024^3);

fprintf('  Durée : %d s = 1 heure\n', duree);
fprintf('  Volume = débit × durée = %.2e bits\n', stockage_bits);
fprintf('  Volume = %.2e octets\n', stockage_octets);
fprintf('  Volume = %.2f Mo\n', stockage_Mo);
fprintf('  Volume = %.4f Go\n', stockage_Go);

%% ---- 8. COMPATIBILITÉ CD ----
fprintf('\n--- 8. Compatibilité avec le standard CD ---\n');

% Caractéristiques CD Audio (Red Book)
Fe_cd = 44100;    % Hz
b_cd_std = 16;    % bits
canaux_cd = 2;    % stéréo
capacite_cd = 700 * 1024^2;  % 700 Mo en octets
duree_cd_max = 80 * 60;      % 80 minutes max

debit_cd = Fe_cd * b_cd_std * canaux_cd;
stockage_cd_1h = debit_cd * 3600 / 8;

fprintf('  Standard CD Audio (Red Book) :\n');
fprintf('    Fe = %d Hz, b = %d bits, stéréo\n', Fe_cd, b_cd_std);
fprintf('    Débit = %.0f bits/s = %.2f Mbits/s\n', debit_cd, debit_cd/1e6);
fprintf('    Capacité CD = %d Mo\n', 700);
fprintf('    Durée max ≈ %.0f min\n', capacite_cd * 8 / debit_cd / 60);

fprintf('\n  Nos paramètres :\n');
fprintf('    Fe = %d Hz, b = %d bits, stéréo\n', Fe, b_final, n_canaux);
if Fe == Fe_cd && b_final == b_cd_std
    fprintf('    --> Paramètres IDENTIQUES au standard CD ✓\n');
elseif Fe == Fe_cd && b_final > b_cd_std
    fprintf('    --> Fe compatible, mais b = %d > 16 bits CD\n', b_final);
    fprintf('    --> Nécessite un format supérieur au CD (DVD-Audio, etc.)\n');
else
    fprintf('    --> Paramètres différents du standard CD\n');
end

stockage_1h = debit_stereo * 3600 / 8;
fprintf('    Stockage 1h = %.2f Mo\n', stockage_1h / (1024^2));
if stockage_1h <= capacite_cd
    fprintf('    --> Compatible avec un CD (%.2f Mo < 700 Mo) ✓\n', stockage_1h/(1024^2));
else
    fprintf('    --> NON compatible avec un CD (%.2f Mo > 700 Mo) ✗\n', stockage_1h/(1024^2));
end

%% ---- 9. TIMBRE DES INSTRUMENTS ----
fprintf('\n--- 9. Respect du timbre des instruments ---\n');
fprintf('  Le timbre est déterminé par les harmoniques du signal.\n');
fprintf('  Un orchestre symphonique produit des sons jusqu''à ~20 kHz.\n');
fprintf('  Avec Fe = %d Hz, on capture les fréquences jusqu''à %d Hz.\n', Fe, Fe/2);
fprintf('  La bande [20 Hz, %d Hz] couvre l''essentiel du spectre audible.\n', Fe/2);

if Fe/2 >= f_max
    fprintf('  --> Le timbre des instruments est respecté ✓\n');
    fprintf('     (toutes les harmoniques audibles sont capturées)\n');
else
    fprintf('  --> Attention : certaines harmoniques audibles sont perdues ✗\n');
end

fprintf('\n  SNR = %.1f dB avec %d bits : la dynamique est suffisante\n', SNR_obtenu, b_final);
fprintf('  pour restituer les nuances d''un orchestre symphonique\n');
fprintf('  (dynamique typique ~60-80 dB).\n');

%% ---- 10. RÉCAPITULATIF ----
fprintf('\n==========================================================\n');
fprintf('  RÉCAPITULATIF\n');
fprintf('==========================================================\n');
fprintf('  Fréquence d''échantillonnage : Fe = %d Hz (%.1f kHz)\n', Fe, Fe/1000);
fprintf('  Nombre de bits             : b = %d bits\n', b_final);
fprintf('  Filtre anti-repliement     : passe-bas, fc = %d Hz\n', f_coupure);
fprintf('  Nombre de canaux           : %d (stéréo)\n', n_canaux);
fprintf('  Débit                      : %.2f Mbits/s\n', debit_stereo/1e6);
fprintf('  Stockage 1h stéréo         : %.2f Mo (%.4f Go)\n', stockage_Mo, stockage_Go);
fprintf('  Compatible CD              : %s\n', string(stockage_1h <= capacite_cd & Fe == Fe_cd & b_final <= 16));
fprintf('  Timbre respecté            : %s\n', string(Fe/2 >= f_max));
fprintf('==========================================================\n');

%% ---- 11. PUISSANCE EN dBm ----
fprintf('\n--- Bonus : Puissance en dBm ---\n');
P_dBm = 10*log10(P_moy / 1e-3);
fprintf('  P_moy = %.0f mW = %.2f dBm\n', P_moy*1000, P_dBm);

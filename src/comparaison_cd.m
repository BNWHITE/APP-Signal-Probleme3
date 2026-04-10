%% ========================================================================
%  COMPARAISON_CD.m - Comparaison avec le standard CD et analyse
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

fprintf('=== Comparaison avec le standard CD Audio ===\n\n');

%% Standard CD Audio (Red Book, 1982)
fprintf('--- Standard CD Audio (Red Book) ---\n');
cd_Fe = 44100;      % Hz
cd_bits = 16;       % bits
cd_canaux = 2;      % stéréo
cd_capacite = 700;  % Mo
cd_duree_max = 80;  % minutes

cd_debit = cd_Fe * cd_bits * cd_canaux;
cd_debit_octet = cd_debit / 8;

fprintf('  Fréquence d''échantillonnage : %d Hz\n', cd_Fe);
fprintf('  Nombre de bits              : %d bits\n', cd_bits);
fprintf('  Nombre de canaux            : %d (stéréo)\n', cd_canaux);
fprintf('  Débit                       : %d bits/s = %.2f kbits/s\n', cd_debit, cd_debit/1000);
fprintf('  Débit en octets             : %.2f Ko/s\n', cd_debit_octet/1024);
fprintf('  Capacité                    : %d Mo\n', cd_capacite);
fprintf('  Durée max                   : %d min\n', cd_duree_max);

% SNR du CD
SNR_cd = 6.02 * cd_bits + 1.76;
fprintf('  SNR (sinus pleine échelle)  : %.2f dB\n', SNR_cd);
fprintf('  Bande passante              : [0, %d] Hz\n', cd_Fe/2);

%% Nos paramètres (Problème III)
fprintf('\n--- Nos paramètres (Problème III) ---\n');

Fe = 44100;     % On choisit le standard CD
b = 16;         % 16 bits suffisent pour >= 90 dB (SNR = 98.09 dB)
n_canaux = 2;
V_max = 0.5;
A = 2 * V_max;
P_moy = 30e-3;

q = A / (2^b);
Pe = q^2 / 12;
SNR = 10*log10(P_moy / Pe);

debit = Fe * b * n_canaux;
debit_octet = debit / 8;

fprintf('  Fe = %d Hz, b = %d bits, %d canaux\n', Fe, b, n_canaux);
fprintf('  Pas de quantification q = %.3e V\n', q);
fprintf('  SNR = %.2f dB (cible : 90 dB)\n', SNR);
fprintf('  Débit = %d bits/s = %.2f kbits/s\n', debit, debit/1000);

%% Stockage
fprintf('\n--- Stockage pour 1 heure de concert stéréo ---\n');

durees_min = [1, 5, 30, 60, 80, 120];  % en minutes
fprintf('\n  Durée (min) | Volume (Mo) | Compatible CD ?\n');
fprintf('  ------------|-------------|---------------\n');
for d = durees_min
    vol_Mo = debit_octet * d * 60 / (1024^2);
    compat = vol_Mo <= cd_capacite;
    fprintf('  %11d | %11.2f | %s\n', d, vol_Mo, string(compat));
end

% 1 heure spécifiquement
vol_1h_Mo = debit_octet * 3600 / (1024^2);
vol_1h_Go = vol_1h_Mo / 1024;
fprintf('\n  Volume pour 1 heure = %.2f Mo = %.4f Go\n', vol_1h_Mo, vol_1h_Go);

if vol_1h_Mo <= cd_capacite
    fprintf('  → Compatible avec un CD (%.2f Mo ≤ %d Mo) ✓\n', vol_1h_Mo, cd_capacite);
else
    fprintf('  → NON compatible avec un CD (%.2f Mo > %d Mo) ✗\n', vol_1h_Mo, cd_capacite);
    fprintf('  → Nécessite %.1f CD ou un support de plus grande capacité\n', vol_1h_Mo/cd_capacite);
end

%% Comparaison avec d'autres formats
fprintf('\n--- Comparaison avec d''autres formats ---\n');

formats = {
    'CD Audio',       44100,  16, 2;
    'DVD Audio',      96000,  24, 2;
    'Blu-ray Audio',  192000, 24, 2;
    'Radio FM',       32000,  16, 2;
    'Téléphonie',     8000,   8,  1;
    'Notre choix',    Fe,     b,  n_canaux;
};

fprintf('\n  %-16s | Fe (Hz) | bits | canaux | Débit (kbits/s) | SNR approx (dB)\n', 'Format');
fprintf('  %s\n', repmat('-', 1, 85));
for i = 1:size(formats, 1)
    nom = formats{i,1};
    fe_f = formats{i,2};
    b_f = formats{i,3};
    c_f = formats{i,4};
    d_f = fe_f * b_f * c_f;
    snr_f = 6.02 * b_f + 1.76;
    fprintf('  %-16s | %7d | %4d | %6d | %15.1f | %14.1f\n', ...
        nom, fe_f, b_f, c_f, d_f/1000, snr_f);
end

%% Analyse du timbre
fprintf('\n--- Compatibilité avec le timbre instrumental ---\n');
fprintf('  Instruments d''un orchestre symphonique :\n');

instruments = {
    'Piccolo',      630,   5000,  12000;
    'Flûte',        260,   2400,   8000;
    'Hautbois',     260,   1600,  10000;
    'Clarinette',   165,   1600,   8000;
    'Basson',        60,    600,   8000;
    'Cor',           60,   1400,   6000;
    'Trompette',    190,   1200,  12000;
    'Trombone',      85,    520,   6000;
    'Tuba',          45,    400,   4000;
    'Violon',       200,   3200,  15000;
    'Alto',         130,   1200,  10000;
    'Violoncelle',   65,    700,   8000;
    'Contrebasse',   40,    300,   6000;
    'Piano',         28,   4200,  15000;
    'Timbales',      90,    200,   6000;
    'Cymbales',     300,  10000,  16000;
};

fprintf('\n  %-14s | Fond. min (Hz) | Fond. max (Hz) | Harmoniques max (Hz) | Capturé ?\n', 'Instrument');
fprintf('  %s\n', repmat('-', 1, 85));
for i = 1:size(instruments, 1)
    nom = instruments{i,1};
    f_fond_min = instruments{i,2};
    f_fond_max = instruments{i,3};
    f_harm_max = instruments{i,4};
    capture = f_harm_max <= Fe/2;
    fprintf('  %-14s | %14d | %14d | %20d | %s\n', ...
        nom, f_fond_min, f_fond_max, f_harm_max, string(capture));
end

fprintf('\n  Avec Fe/2 = %d Hz, toutes les harmoniques audibles sont capturées.\n', Fe/2);
fprintf('  → Le timbre des instruments est respecté ✓\n');

%% Conclusion
fprintf('\n=============================================\n');
fprintf('  CONCLUSION\n');
fprintf('=============================================\n');
fprintf('  Les paramètres Fe = %d Hz et b = %d bits :\n', Fe, b);
fprintf('  - Sont IDENTIQUES au standard CD Audio\n');
fprintf('  - Garantissent un SNR de %.1f dB (> 90 dB cible)\n', SNR);
fprintf('  - Permettent de stocker %.1f min sur un CD de %d Mo\n', ...
    cd_capacite * 1024^2 * 8 / debit / 60, cd_capacite);
fprintf('  - Respectent le timbre de tous les instruments\n');
fprintf('    d''un orchestre symphonique\n');
fprintf('  - Le standard CD a été conçu exactement pour\n');
fprintf('    l''enregistrement audio haute fidélité !\n');
fprintf('=============================================\n');

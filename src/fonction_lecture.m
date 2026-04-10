function [Fe, b, A, P_moy, n_canaux] = fonction_lecture()
%% FONCTION_LECTURE - Lecture des paramètres du problème
%  Rien en entrée, valeurs en sortie
%
%  Sorties :
%    Fe       - Fréquence d'échantillonnage (Hz)
%    b        - Nombre de bits de quantification
%    A        - Dynamique totale du micro (V)
%    P_moy    - Puissance moyenne en sortie du micro (W)
%    n_canaux - Nombre de canaux (1=mono, 2=stéréo)
%
%  APP Signal - ISEP 2025-2026 - Problème III

    %% Données du cahier des charges
    f_max    = 20000;       % Fréquence max audible (Hz)
    V_max    = 0.5;         % Amplitude crête du micro (V)
    SNR_cible = 90;         % SNR cible (dB)

    %% Calcul de Fe (Shannon : Fe >= 2*f_max)
    Fe = 44100;             % Choix standard CD (Hz)

    %% Calcul du nombre de bits (SNR = -4.44 + 6.02*b >= 90 dB)
    A     = 2 * V_max;      % Dynamique totale = 1 V
    P_moy = 30e-3;          % Puissance moyenne (W)
    C     = 10*log10(12 * P_moy / A^2);
    b     = ceil((SNR_cible - C) / (20*log10(2)));
    b     = max(b, 16);     % Minimum 16 bits

    %% Mode stéréo
    n_canaux = 2;

    %% Affichage
    fprintf('=== fonction_lecture : paramètres lus ===\n');
    fprintf('  Fe       = %d Hz\n', Fe);
    fprintf('  b        = %d bits\n', b);
    fprintf('  A        = %.1f V\n', A);
    fprintf('  P_moy    = %.0f mW\n', P_moy*1000);
    fprintf('  n_canaux = %d\n', n_canaux);
end

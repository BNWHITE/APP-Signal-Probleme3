function [SNR, debit, stockage_Mo] = fonction_calcul(Fe, b, A, P_moy, n_canaux)
%% FONCTION_CALCUL - Calcul des grandeurs de numérisation
%  Valeurs en entrée, valeurs en sortie
%
%  Entrées :
%    Fe       - Fréquence d'échantillonnage (Hz)
%    b        - Nombre de bits
%    A        - Dynamique totale (V)
%    P_moy    - Puissance moyenne (W)
%    n_canaux - Nombre de canaux
%
%  Sorties :
%    SNR         - Rapport signal à bruit de quantification (dB)
%    debit       - Débit binaire stéréo (bits/s)
%    stockage_Mo - Volume de stockage pour 1h (Mo)
%
%  APP Signal - ISEP 2025-2026 - Problème III

    %% SNR de quantification
    q   = A / (2^b);          % Pas de quantification (V)
    Pe  = q^2 / 12;           % Puissance du bruit de quantification (W)
    SNR = 10*log10(P_moy/Pe); % SNR (dB)

    %% Débit binaire
    debit = Fe * b * n_canaux; % bits/s

    %% Stockage pour 1 heure
    duree       = 3600;                        % 1 heure (s)
    stockage_Mo = debit * duree / 8 / (1024^2); % Mo

    %% Affichage
    fprintf('=== fonction_calcul : résultats ===\n');
    fprintf('  q           = %.3e V\n', q);
    fprintf('  SNR         = %.2f dB\n', SNR);
    fprintf('  Débit       = %.2f kbits/s\n', debit/1000);
    fprintf('  Stockage 1h = %.2f Mo\n', stockage_Mo);
end

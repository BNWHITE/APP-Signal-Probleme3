% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   lire_parametres_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Lit et détermine les paramètres de numérisation d'un signal
%   audio haute fidélité à partir du cahier des charges :
%     - Bande [20 Hz, 20 000 Hz], SNR >= 90 dB
%     - Micro idéal, dynamique [-500mV, +500mV], P_moy = 30 mW
%   Applique le théorème de Shannon pour Fe et calcule le
%   nombre de bits b nécessaire pour atteindre le SNR cible.
%
% ENTREES :
%   Aucune
%
% SORTIES :
%   - params : structure contenant les champs suivants :
%       .f_min      : scalaire (double) — Fréquence min (Hz)
%       .f_max      : scalaire (double) — Fréquence max (Hz)
%       .SNR_cible  : scalaire (double) — SNR cible (dB)
%       .V_max      : scalaire (double) — Tension crête micro (V)
%       .A          : scalaire (double) — Dynamique totale (V)
%       .P_moy      : scalaire (double) — Puissance moyenne (W)
%       .Fe         : scalaire (double) — Fréquence d'échantillonnage (Hz)
%       .b          : scalaire (double) — Nombre de bits
%       .n_canaux   : scalaire (double) — Nombre de canaux (2=stéréo)
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

function params = lire_parametres_numerisation()

    %% Cahier des charges
    params.f_min     = 20;          % Hz
    params.f_max     = 20000;       % Hz
    params.SNR_cible = 90;          % dB
    params.V_max     = 0.5;         % V (500 mV)
    params.A         = 2 * 0.5;     % Dynamique totale = 1 V
    params.P_moy     = 30e-3;       % 30 mW
    params.n_canaux  = 2;           % Stéréo

    %% Fréquence d'échantillonnage (Shannon : Fe >= 2*f_max)
    % On choisit le standard CD : 44 100 Hz
    % Cela donne Fe/2 = 22 050 Hz > 20 000 Hz
    params.Fe = 44100;                                          %G2D

    %% Nombre de bits
    % SNR = 10*log10(12*P_moy/A^2) + 6.02*b
    % On résout b >= (SNR_cible - C) / 6.02
    C = 10*log10(12 * params.P_moy / params.A^2);
    b_min = ceil((params.SNR_cible - C) / (20*log10(2)));
    params.b = max(b_min, 16);                                  %G2D

end

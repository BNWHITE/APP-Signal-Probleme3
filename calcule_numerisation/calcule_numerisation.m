% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   calcule_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Calcule toutes les grandeurs liées à la numérisation
%   d'un signal audio haute fidélité :
%     - Pas de quantification, puissance du bruit de quantification
%     - SNR effectif de quantification
%     - Débit binaire (mono et stéréo)
%     - Volume de stockage pour une durée donnée
%     - Compatibilité CD et respect du timbre
%
% ENTREES :
%   - params : structure — Paramètres issus de lire_parametres_numerisation
%       .Fe, .b, .A, .P_moy, .n_canaux, .f_max, .SNR_cible
%   - duree  : scalaire (double) — Durée d'enregistrement (s)
%
% SORTIES :
%   - resultats : structure contenant les champs suivants :
%       .q             : scalaire (double) — Pas de quantification (V)
%       .Pe            : scalaire (double) — Puissance bruit quant. (W)
%       .SNR           : scalaire (double) — SNR obtenu (dB)
%       .debit_mono    : scalaire (double) — Débit mono (bits/s)
%       .debit_stereo  : scalaire (double) — Débit stéréo (bits/s)
%       .stockage_Mo   : scalaire (double) — Volume de stockage (Mo)
%       .compatible_cd : scalaire (logical) — Vrai si compatible CD
%       .timbre_ok     : scalaire (logical) — Vrai si timbre respecté
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

function resultats = calcule_numerisation(params, duree)

    %% Pas de quantification
    resultats.q  = params.A / (2^params.b);                     %G2D

    %% Puissance du bruit de quantification
    resultats.Pe = resultats.q^2 / 12;                          %G2D

    %% SNR effectif
    resultats.SNR = 10*log10(params.P_moy / resultats.Pe);      %G2D

    %% Débit binaire
    resultats.debit_mono   = params.Fe * params.b;              %G2D
    resultats.debit_stereo = resultats.debit_mono * params.n_canaux; %G2D

    %% Volume de stockage
    volume_bits   = resultats.debit_stereo * duree;
    volume_octets = volume_bits / 8;
    resultats.stockage_Mo = volume_octets / (1024^2);           %G2D

    %% Compatibilité CD (Red Book : 44100 Hz, 16 bits, capacité 700 Mo)
    resultats.compatible_cd = (params.Fe == 44100) && ...
                              (params.b <= 16) && ...
                              (resultats.stockage_Mo <= 700);   %G2D

    %% Timbre : respecté si Fe/2 >= f_max (harmoniques audibles captées)
    resultats.timbre_ok = (params.Fe / 2) >= params.f_max;      %G2D

end

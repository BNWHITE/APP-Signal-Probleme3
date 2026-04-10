% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   affiche_resultats_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Affiche le récapitulatif complet des résultats de la
%   numérisation audio haute fidélité :
%     - Tableau des paramètres et grandeurs calculées
%     - Schéma fonctionnel en console
%     - Vérifications (SNR, compatibilité CD, timbre)
%
% ENTREES :
%   - params    : structure — Paramètres (issus de lire_parametres_numerisation)
%   - resultats : structure — Résultats (issus de calcule_numerisation)
%
% SORTIES :
%   Aucune (affichage console uniquement)
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

function affiche_resultats_numerisation(params, resultats)

    %% Schéma fonctionnel
    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('  PROBLEME III — Numérisation audio haute fidélité\n');
    fprintf('============================================================\n\n');

    fprintf('  Schéma fonctionnel :\n');
    fprintf('  [Micro] → [Filtre anti-repliement] → [Échantillonneur] → [Quantificateur] → [Codeur]\n');
    fprintf('  (idéal)    (passe-bas fc<Fe/2)        (Fe=%d Hz)       (b=%d bits)       (stéréo)\n\n', params.Fe, params.b);

    %% Tableau récapitulatif
    fprintf('  %-35s | %-20s\n', 'Paramètre', 'Valeur');
    fprintf('  %s-+-%s\n', repmat('-',1,35), repmat('-',1,20)); %G2D
    fprintf('  %-35s | [%d Hz, %d Hz]\n', 'Bande de fréquences', params.f_min, params.f_max);
    fprintf('  %-35s | %d Hz\n', 'Fréquence d''échantillonnage (Fe)', params.Fe);
    fprintf('  %-35s | %d bits\n', 'Nombre de bits (b)', params.b);
    fprintf('  %-35s | %.3e V\n', 'Pas de quantification (q)', resultats.q);
    fprintf('  %-35s | %d\n', 'Niveaux de quantification', 2^params.b);
    fprintf('  %-35s | %.2f dB\n', 'SNR de quantification', resultats.SNR);
    fprintf('  %-35s | %d (stéréo)\n', 'Nombre de canaux', params.n_canaux);
    fprintf('  %-35s | %.2f kbits/s\n', 'Débit stéréo', resultats.debit_stereo/1000);
    fprintf('  %-35s | %.2f Mo\n', 'Stockage 1h stéréo', resultats.stockage_Mo);
    fprintf('  %s-+-%s\n', repmat('-',1,35), repmat('-',1,20));

    %% Vérifications
    fprintf('\n  --- Vérifications ---\n');                      %G2D

    % SNR
    if resultats.SNR >= params.SNR_cible
        fprintf('  [OK]  SNR = %.2f dB >= %d dB\n', resultats.SNR, params.SNR_cible);
    else
        fprintf('  [NON] SNR = %.2f dB < %d dB\n', resultats.SNR, params.SNR_cible);
    end

    % Compatible CD
    if resultats.compatible_cd
        fprintf('  [OK]  Compatible CD (%.1f Mo <= 700 Mo, Fe=44100, b=16)\n', resultats.stockage_Mo);
    else
        fprintf('  [NON] Non compatible CD\n');
    end

    % Timbre
    if resultats.timbre_ok
        fprintf('  [OK]  Timbre respecté (Fe/2 = %d Hz >= f_max = %d Hz)\n', params.Fe/2, params.f_max);
    else
        fprintf('  [NON] Timbre non respecté\n');
    end

    fprintf('\n============================================================\n'); %G2D

end

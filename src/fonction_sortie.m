function fonction_sortie(SNR, debit, stockage_Mo)
%% FONCTION_SORTIE - Affichage des résultats et conclusion
%  Valeurs en entrée, rien en sortie
%
%  Entrées :
%    SNR         - Rapport signal à bruit (dB)
%    debit       - Débit binaire stéréo (bits/s)
%    stockage_Mo - Volume de stockage pour 1h (Mo)
%
%  APP Signal - ISEP 2025-2026 - Problème III

    %% Tableau récapitulatif
    fprintf('\n========================================\n');
    fprintf('  RÉSULTATS - Problème III\n');
    fprintf('========================================\n');
    fprintf('  SNR         : %.2f dB\n', SNR);
    fprintf('  Débit       : %.2f kbits/s\n', debit/1000);
    fprintf('  Stockage 1h : %.2f Mo\n', stockage_Mo);

    %% Vérifications
    fprintf('\n--- Vérifications ---\n');

    if SNR >= 90
        fprintf('  SNR >= 90 dB       : OK\n');
    else
        fprintf('  SNR >= 90 dB       : NON\n');
    end

    if stockage_Mo <= 700
        fprintf('  Compatible CD      : OUI (%.1f Mo < 700 Mo)\n', stockage_Mo);
    else
        fprintf('  Compatible CD      : NON (%.1f Mo > 700 Mo)\n', stockage_Mo);
    end

    fprintf('========================================\n');
end

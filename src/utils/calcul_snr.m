function snr_dB = calcul_snr(x, x_q)
%CALCUL_SNR Calcule le rapport signal à bruit (SNR) en dB
%  snr_dB = calcul_snr(x, x_q)
%  
%  Entrées :
%    x   - signal original
%    x_q - signal quantifié
%  
%  Sortie :
%    snr_dB - rapport signal à bruit en dB
%
%  APP Signal - ISEP 2025-2026

    e = x - x_q;              % erreur de quantification
    P_signal = mean(x.^2);    % puissance du signal
    P_erreur = mean(e.^2);    % puissance de l'erreur
    
    if P_erreur > 0
        snr_dB = 10 * log10(P_signal / P_erreur);
    else
        snr_dB = Inf;
    end
end

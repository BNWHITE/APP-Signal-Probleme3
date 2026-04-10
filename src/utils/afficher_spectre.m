function afficher_spectre(x, Fe, titre)
%AFFICHER_SPECTRE Affiche le spectre d'un signal (module de la FFT)
%  afficher_spectre(x, Fe, titre)
%
%  Entrées :
%    x     - signal temporel
%    Fe    - fréquence d'échantillonnage (Hz)
%    titre - titre du graphique (optionnel)
%
%  APP Signal - ISEP 2025-2026

    if nargin < 3
        titre = 'Spectre du signal';
    end
    
    N = length(x);
    M = 2^nextpow2(N);  % Zéro-padding pour meilleure résolution
    
    X = abs(fft(x, M)) / N;
    X = X(1:M/2+1);
    X(2:end-1) = 2 * X(2:end-1);
    
    f = (0:M/2) * Fe / M;
    
    subplot(1,2,1);
    plot(f/1000, X, 'b', 'LineWidth', 1);
    xlabel('Fréquence (kHz)');
    ylabel('Amplitude');
    title([titre ' (linéaire)']);
    grid on;
    xlim([0, Fe/2/1000]);
    
    subplot(1,2,2);
    X_dB = 20*log10(X / max(X) + eps);
    plot(f/1000, X_dB, 'b', 'LineWidth', 1);
    xlabel('Fréquence (kHz)');
    ylabel('Amplitude (dB)');
    title([titre ' (dB)']);
    grid on;
    xlim([0, Fe/2/1000]);
    ylim([-100, 5]);
end

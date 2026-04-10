function [x, t] = generer_signal_test(f0, A, Fe, duree, type)
%GENERER_SIGNAL_TEST Génère un signal de test pour la simulation
%  [x, t] = generer_signal_test(f0, A, Fe, duree, type)
%
%  Entrées :
%    f0    - fréquence fondamentale (Hz)
%    A     - amplitude crête (V)
%    Fe    - fréquence d'échantillonnage (Hz)
%    duree - durée du signal (s)
%    type  - type de signal : 'sinus', 'multi_harmoniques', 'bruit_blanc'
%
%  Sorties :
%    x - signal généré
%    t - vecteur temps
%
%  APP Signal - ISEP 2025-2026

    if nargin < 5
        type = 'sinus';
    end
    
    t = 0:1/Fe:(duree - 1/Fe);
    
    switch lower(type)
        case 'sinus'
            x = A * sin(2*pi*f0*t);
            
        case 'multi_harmoniques'
            % Signal riche en harmoniques (timbre de violon simulé)
            n_harm = floor((Fe/2) / f0);
            n_harm = min(n_harm, 20);
            x = zeros(size(t));
            for k = 1:n_harm
                x = x + (A/k) * sin(2*pi*k*f0*t);
            end
            x = x / max(abs(x)) * A;  % normalisation
            
        case 'bruit_blanc'
            x = A * (2*rand(size(t)) - 1);
            
        otherwise
            error('Type de signal non reconnu : %s', type);
    end
end

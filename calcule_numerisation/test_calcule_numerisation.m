% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_calcule_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Script de test unitaire pour la fonction calcule_numerisation.
%   10 cas de test vérifiant les calculs de SNR, débit, stockage,
%   compatibilité CD et timbre.
%
% FONCTION TESTEE :
%   calcule_numerisation(params, duree)
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST calcule_numerisation ===\n\n');

%% Préparation : paramètres du cahier des charges
addpath(fullfile('..','lire_parametres_numerisation'));
params = lire_parametres_numerisation();
duree  = 3600;  % 1 heure

resultats = calcule_numerisation(params, duree);

%% Cas 1 : La sortie est une structure
fprintf('Cas 1  : resultats est une structure → %s\n', iif(isstruct(resultats),'OK','ECHEC'));

%% Cas 2 : Pas de quantification q = A / 2^b
q_attendu = params.A / (2^params.b);
fprintf('Cas 2  : q = %.3e V (attendu %.3e) → %s\n', resultats.q, q_attendu, iif(abs(resultats.q - q_attendu)<1e-20,'OK','ECHEC'));

%% Cas 3 : Puissance bruit Pe = q²/12
Pe_attendu = q_attendu^2 / 12;
fprintf('Cas 3  : Pe = %.3e W (attendu %.3e) → %s\n', resultats.Pe, Pe_attendu, iif(abs(resultats.Pe - Pe_attendu)<1e-25,'OK','ECHEC'));

%% Cas 4 : SNR >= 90 dB
fprintf('Cas 4  : SNR = %.2f dB >= 90 dB → %s\n', resultats.SNR, iif(resultats.SNR >= 90,'OK','ECHEC'));

%% Cas 5 : Débit mono = Fe × b
debit_mono_attendu = params.Fe * params.b;
fprintf('Cas 5  : debit_mono = %d bits/s (attendu %d) → %s\n', resultats.debit_mono, debit_mono_attendu, iif(resultats.debit_mono==debit_mono_attendu,'OK','ECHEC'));

%% Cas 6 : Débit stéréo = Fe × b × 2
debit_stereo_attendu = debit_mono_attendu * 2;
fprintf('Cas 6  : debit_stereo = %d bits/s (attendu %d) → %s\n', resultats.debit_stereo, debit_stereo_attendu, iif(resultats.debit_stereo==debit_stereo_attendu,'OK','ECHEC'));

%% Cas 7 : Stockage 1h stéréo < 700 Mo
fprintf('Cas 7  : stockage = %.2f Mo < 700 Mo → %s\n', resultats.stockage_Mo, iif(resultats.stockage_Mo < 700,'OK','ECHEC'));

%% Cas 8 : Compatible CD
fprintf('Cas 8  : compatible_cd = %d (attendu 1) → %s\n', resultats.compatible_cd, iif(resultats.compatible_cd,'OK','ECHEC'));

%% Cas 9 : Timbre respecté
fprintf('Cas 9  : timbre_ok = %d (attendu 1) → %s\n', resultats.timbre_ok, iif(resultats.timbre_ok,'OK','ECHEC'));

%% Cas 10 : Test avec durée courte (30 min) — stockage proportionnel
res30 = calcule_numerisation(params, 1800);
ratio = resultats.stockage_Mo / res30.stockage_Mo;
fprintf('Cas 10 : stockage(1h) / stockage(30min) = %.2f (attendu 2.00) → %s\n', ratio, iif(abs(ratio-2)<0.01,'OK','ECHEC'));

fprintf('\n=== FIN ===\n');

function s = iif(c,a,b); if c, s=a; else s=b; end; end

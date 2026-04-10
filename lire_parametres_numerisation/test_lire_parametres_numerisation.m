% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_lire_parametres_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Script de test unitaire pour la fonction
%   lire_parametres_numerisation.
%   10 cas de test vérifiant la cohérence des paramètres lus.
%
% FONCTION TESTEE :
%   lire_parametres_numerisation()
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST lire_parametres_numerisation ===\n\n');

params = lire_parametres_numerisation();

%% Cas 1 : La structure est bien renvoyée
fprintf('Cas 1  : params est une structure → %s\n', iif(isstruct(params),'OK','ECHEC'));

%% Cas 2 : f_min = 20 Hz
fprintf('Cas 2  : f_min = %g Hz (attendu 20) → %s\n', params.f_min, iif(params.f_min==20,'OK','ECHEC'));

%% Cas 3 : f_max = 20 000 Hz
fprintf('Cas 3  : f_max = %g Hz (attendu 20000) → %s\n', params.f_max, iif(params.f_max==20000,'OK','ECHEC'));

%% Cas 4 : SNR_cible = 90 dB
fprintf('Cas 4  : SNR_cible = %g dB (attendu 90) → %s\n', params.SNR_cible, iif(params.SNR_cible==90,'OK','ECHEC'));

%% Cas 5 : V_max = 0.5 V
fprintf('Cas 5  : V_max = %g V (attendu 0.5) → %s\n', params.V_max, iif(params.V_max==0.5,'OK','ECHEC'));

%% Cas 6 : A = 2*V_max = 1 V
fprintf('Cas 6  : A = %g V (attendu 1) → %s\n', params.A, iif(params.A==1,'OK','ECHEC'));

%% Cas 7 : P_moy = 30 mW
fprintf('Cas 7  : P_moy = %g mW (attendu 30) → %s\n', params.P_moy*1000, iif(params.P_moy==30e-3,'OK','ECHEC'));

%% Cas 8 : Fe respecte Shannon (Fe >= 2*f_max = 40 000)
fprintf('Cas 8  : Fe = %d Hz >= 2*f_max = %d Hz → %s\n', params.Fe, 2*params.f_max, iif(params.Fe>=2*params.f_max,'OK','ECHEC'));

%% Cas 9 : b >= 16 bits (minimum standard CD)
fprintf('Cas 9  : b = %d bits >= 16 → %s\n', params.b, iif(params.b>=16,'OK','ECHEC'));

%% Cas 10 : Le SNR avec ces paramètres atteint bien la cible
q  = params.A / (2^params.b);
Pe = q^2 / 12;
SNR_obtenu = 10*log10(params.P_moy / Pe);
fprintf('Cas 10 : SNR obtenu = %.2f dB >= %d dB → %s\n', SNR_obtenu, params.SNR_cible, iif(SNR_obtenu>=params.SNR_cible,'OK','ECHEC'));

fprintf('\n=== FIN ===\n');

function s = iif(c,a,b); if c, s=a; else s=b; end; end

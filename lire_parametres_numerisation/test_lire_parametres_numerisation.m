% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_lire_parametres_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   12 Avril 2026
%
% DESCRIPTION :
%   Script de test unitaire pour la fonction
%   lire_parametres_numerisation.
%   10 cas de test verifiant la coherence des parametres
%   du cahier des charges. Inclut des verifications positives
%   (valeurs correctes) et negatives (coherence interne).
%
% FONCTION TESTEE :
%   lire_parametres_numerisation()
%
% MODIFICATIONS :
%   12/04/26 — Version finale avec cas positifs et negatifs
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST lire_parametres_numerisation ===\n\n');

params = lire_parametres_numerisation();

nb_ok = 0;
nb_total = 10;

%% Cas 1 : La sortie est une structure
r1 = isstruct(params);
nb_ok = nb_ok + r1;
fprintf('Cas 1  : params est une structure              -> %s\n', iif(r1,'OK','ECHEC'));

%% Cas 2 : Tous les champs requis sont presents (9 champs)
champs_requis = {'f_min','f_max','SNR_cible','V_max','A','P_moy','Fe','b','n_canaux'};
nb_champs = 0;
for i = 1:length(champs_requis)
    nb_champs = nb_champs + isfield(params, champs_requis{i});
end
r2 = (nb_champs == 9);
nb_ok = nb_ok + r2;
fprintf('Cas 2  : %d/9 champs presents (attendu 9)     -> %s\n', nb_champs, iif(r2,'OK','ECHEC'));

%% Cas 3 : f_min = 20 Hz et f_max = 20000 Hz
r3 = (params.f_min == 20) && (params.f_max == 20000);
nb_ok = nb_ok + r3;
fprintf('Cas 3  : f_min=%g, f_max=%g (attendu 20, 20000) -> %s\n', params.f_min, params.f_max, iif(r3,'OK','ECHEC'));

%% Cas 4 : f_min < f_max (coherence — test negatif si inverse)
r4 = (params.f_min < params.f_max);
nb_ok = nb_ok + r4;
fprintf('Cas 4  : f_min < f_max (%g < %g)              -> %s\n', params.f_min, params.f_max, iif(r4,'OK','ECHEC'));

%% Cas 5 : V_max > 0 et A = 2*V_max (coherence interne)
r5 = (params.V_max > 0) && (abs(params.A - 2*params.V_max) < 1e-10);
nb_ok = nb_ok + r5;
fprintf('Cas 5  : A = 2*V_max ? A=%g, 2*V_max=%g       -> %s\n', params.A, 2*params.V_max, iif(r5,'OK','ECHEC'));

%% Cas 6 : P_moy > 0 (puissance physiquement positive)
r6 = (params.P_moy > 0);
nb_ok = nb_ok + r6;
fprintf('Cas 6  : P_moy = %g W > 0                     -> %s\n', params.P_moy, iif(r6,'OK','ECHEC'));

%% Cas 7 : Fe respecte Shannon (Fe >= 2*f_max)
r7 = (params.Fe >= 2*params.f_max);
nb_ok = nb_ok + r7;
fprintf('Cas 7  : Fe=%d >= 2*f_max=%d (Shannon)         -> %s\n', params.Fe, 2*params.f_max, iif(r7,'OK','ECHEC'));

%% Cas 8 : Fe n'est PAS strictement egal a 2*f_max (marge necessaire)
%    On verifie qu'il y a une marge > 0 Hz (sinon on est pile a la limite)
r8 = (params.Fe > 2*params.f_max);
nb_ok = nb_ok + r8;
fprintf('Cas 8  : Fe > 2*f_max (marge : %d Hz)          -> %s\n', params.Fe - 2*params.f_max, iif(r8,'OK','ECHEC'));

%% Cas 9 : b >= 16 bits (minimum standard CD)
r9 = (params.b >= 16);
nb_ok = nb_ok + r9;
fprintf('Cas 9  : b = %d bits >= 16                     -> %s\n', params.b, iif(r9,'OK','ECHEC'));

%% Cas 10 : SNR atteint la cible avec ces parametres
q  = params.A / (2^params.b);
Pe = q^2 / 12;
SNR_obtenu = 10*log10(params.P_moy / Pe);
r10 = (SNR_obtenu >= params.SNR_cible);
nb_ok = nb_ok + r10;
fprintf('Cas 10 : SNR obtenu = %.2f dB >= %d dB         -> %s\n', SNR_obtenu, params.SNR_cible, iif(r10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== FIN ===\n');

function s = iif(c, a, b); if c, s = a; else, s = b; end; end

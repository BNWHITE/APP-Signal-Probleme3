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
%   lus par rapport au cahier des charges.
%
% FONCTION TESTEE :
%   lire_parametres_numerisation()
%
% MODIFICATIONS :
%   12/04/26 — Ajout des resultats numeriques attendus et resume
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST lire_parametres_numerisation ===\n\n');

params = lire_parametres_numerisation();

nb_ok = 0;
nb_total = 10;

%% Cas 1 : La structure est bien renvoyee
r1 = isstruct(params);
nb_ok = nb_ok + r1;
fprintf('Cas 1  : params est une structure           -> %s\n', iif(r1,'OK','ECHEC'));

%% Cas 2 : f_min = 20 Hz
r2 = (params.f_min == 20);
nb_ok = nb_ok + r2;
fprintf('Cas 2  : f_min = %g Hz (attendu 20)         -> %s\n', params.f_min, iif(r2,'OK','ECHEC'));

%% Cas 3 : f_max = 20 000 Hz
r3 = (params.f_max == 20000);
nb_ok = nb_ok + r3;
fprintf('Cas 3  : f_max = %g Hz (attendu 20000)      -> %s\n', params.f_max, iif(r3,'OK','ECHEC'));

%% Cas 4 : SNR_cible = 90 dB
r4 = (params.SNR_cible == 90);
nb_ok = nb_ok + r4;
fprintf('Cas 4  : SNR_cible = %g dB (attendu 90)     -> %s\n', params.SNR_cible, iif(r4,'OK','ECHEC'));

%% Cas 5 : V_max = 0.5 V
r5 = (params.V_max == 0.5);
nb_ok = nb_ok + r5;
fprintf('Cas 5  : V_max = %g V (attendu 0.5)         -> %s\n', params.V_max, iif(r5,'OK','ECHEC'));

%% Cas 6 : A = 2*V_max = 1 V
r6 = (params.A == 1);
nb_ok = nb_ok + r6;
fprintf('Cas 6  : A = %g V (attendu 1)               -> %s\n', params.A, iif(r6,'OK','ECHEC'));

%% Cas 7 : P_moy = 30 mW = 0.030 W
r7 = (params.P_moy == 30e-3);
nb_ok = nb_ok + r7;
fprintf('Cas 7  : P_moy = %.1f mW (attendu 30)       -> %s\n', params.P_moy*1000, iif(r7,'OK','ECHEC'));

%% Cas 8 : Fe respecte Shannon (Fe >= 2*f_max = 40 000 Hz)
r8 = (params.Fe >= 2*params.f_max);
nb_ok = nb_ok + r8;
fprintf('Cas 8  : Fe = %d Hz >= 2*f_max = %d Hz      -> %s\n', params.Fe, 2*params.f_max, iif(r8,'OK','ECHEC'));

%% Cas 9 : b >= 16 bits (minimum standard CD)
r9 = (params.b >= 16);
nb_ok = nb_ok + r9;
fprintf('Cas 9  : b = %d bits >= 16                   -> %s\n', params.b, iif(r9,'OK','ECHEC'));

%% Cas 10 : Le SNR obtenu avec ces parametres atteint la cible
q  = params.A / (2^params.b);
Pe = q^2 / 12;
SNR_obtenu = 10*log10(params.P_moy / Pe);
r10 = (SNR_obtenu >= params.SNR_cible);
nb_ok = nb_ok + r10;
fprintf('Cas 10 : SNR obtenu = %.2f dB >= %d dB      -> %s\n', SNR_obtenu, params.SNR_cible, iif(r10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== FIN ===\n');

function s = iif(c, a, b); if c, s = a; else, s = b; end; end

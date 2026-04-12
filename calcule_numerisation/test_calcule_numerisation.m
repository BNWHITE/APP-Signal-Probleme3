% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_calcule_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   12 Avril 2026
%
% DESCRIPTION :
%   Script de test unitaire pour la fonction calcule_numerisation.
%   10 cas de test verifiant les calculs de SNR, debit, stockage,
%   compatibilite CD et timbre.
%
% FONCTION TESTEE :
%   calcule_numerisation(params, duree)
%
% MODIFICATIONS :
%   12/04/26 — Resultats numeriques verifies et resume ajoute
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST calcule_numerisation ===\n\n');

%% Preparation : parametres du cahier des charges
addpath(fullfile('..','lire_parametres_numerisation'));
params = lire_parametres_numerisation();
duree  = 3600;  % 1 heure

resultats = calcule_numerisation(params, duree);

nb_ok = 0;
nb_total = 10;

%% Cas 1 : La sortie est une structure
r1 = isstruct(resultats);
nb_ok = nb_ok + r1;
fprintf('Cas 1  : resultats est une structure         -> %s\n', iif(r1,'OK','ECHEC'));

%% Cas 2 : Pas de quantification q = A / 2^b
q_attendu = params.A / (2^params.b);
r2 = (abs(resultats.q - q_attendu) < 1e-15);
nb_ok = nb_ok + r2;
fprintf('Cas 2  : q = %.6e V (attendu %.6e)   -> %s\n', resultats.q, q_attendu, iif(r2,'OK','ECHEC'));

%% Cas 3 : Puissance bruit Pe = q^2/12
Pe_attendu = q_attendu^2 / 12;
r3 = (abs(resultats.Pe - Pe_attendu) < 1e-20);
nb_ok = nb_ok + r3;
fprintf('Cas 3  : Pe = %.6e W (attendu %.6e)  -> %s\n', resultats.Pe, Pe_attendu, iif(r3,'OK','ECHEC'));

%% Cas 4 : SNR >= 90 dB
SNR_attendu = 10*log10(params.P_moy / Pe_attendu);
r4 = (resultats.SNR >= 90);
nb_ok = nb_ok + r4;
fprintf('Cas 4  : SNR = %.2f dB >= 90 dB (attendu %.2f) -> %s\n', resultats.SNR, SNR_attendu, iif(r4,'OK','ECHEC'));

%% Cas 5 : Debit mono = Fe * b
debit_mono_attendu = params.Fe * params.b;
r5 = (resultats.debit_mono == debit_mono_attendu);
nb_ok = nb_ok + r5;
fprintf('Cas 5  : debit_mono = %d bits/s (attendu %d)    -> %s\n', resultats.debit_mono, debit_mono_attendu, iif(r5,'OK','ECHEC'));

%% Cas 6 : Debit stereo = Fe * b * n_canaux
debit_stereo_attendu = debit_mono_attendu * params.n_canaux;
r6 = (resultats.debit_stereo == debit_stereo_attendu);
nb_ok = nb_ok + r6;
fprintf('Cas 6  : debit_stereo = %d bits/s (attendu %d)  -> %s\n', resultats.debit_stereo, debit_stereo_attendu, iif(r6,'OK','ECHEC'));

%% Cas 7 : Stockage 1h stereo < 700 Mo
r7 = (resultats.stockage_Mo < 700);
nb_ok = nb_ok + r7;
fprintf('Cas 7  : stockage = %.2f Mo < 700 Mo            -> %s\n', resultats.stockage_Mo, iif(r7,'OK','ECHEC'));

%% Cas 8 : Compatible CD
r8 = resultats.compatible_cd;
nb_ok = nb_ok + r8;
fprintf('Cas 8  : compatible_cd = %d (attendu 1)         -> %s\n', resultats.compatible_cd, iif(r8,'OK','ECHEC'));

%% Cas 9 : Timbre respecte
r9 = resultats.timbre_ok;
nb_ok = nb_ok + r9;
fprintf('Cas 9  : timbre_ok = %d (attendu 1)             -> %s\n', resultats.timbre_ok, iif(r9,'OK','ECHEC'));

%% Cas 10 : Proportionnalite du stockage (duree double = stockage double)
res30 = calcule_numerisation(params, 1800);
ratio = resultats.stockage_Mo / res30.stockage_Mo;
r10 = (abs(ratio - 2) < 0.01);
nb_ok = nb_ok + r10;
fprintf('Cas 10 : stockage(1h)/stockage(30min) = %.2f (attendu 2.00) -> %s\n', ratio, iif(r10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== FIN ===\n');

function s = iif(c,a,b); if c, s=a; else s=b; end; end

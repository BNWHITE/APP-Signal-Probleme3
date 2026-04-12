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
%   10 cas de test incluant :
%     - Cas positifs : parametres Hi-Fi nominaux (tout OK)
%     - Cas negatifs : parametres degrades pour verifier que la
%       fonction detecte bien les problemes (SNR<90, non compatible
%       CD, timbre non respecte).
%
% FONCTION TESTEE :
%   calcule_numerisation(params, duree)
%
% MODIFICATIONS :
%   12/04/26 — Version finale avec cas positifs et negatifs
% #------------------------------------------

clear all; close all; clc;

fprintf('=== TEST calcule_numerisation ===\n\n');

addpath(fullfile('..','lire_parametres_numerisation'));

nb_ok = 0;
nb_total = 10;

% =============================================
%  PARTIE A — CAS POSITIFS (parametres Hi-Fi)
% =============================================
fprintf('--- Partie A : Cas positifs (Hi-Fi nominal) ---\n');
params = lire_parametres_numerisation();
duree  = 3600;
resultats = calcule_numerisation(params, duree);

%% Cas 1 : La sortie est une structure
r1 = isstruct(resultats);
nb_ok = nb_ok + r1;
fprintf('Cas 1  : resultats est une structure                 -> %s\n', iif(r1,'OK','ECHEC'));

%% Cas 2 : Pas de quantification q = A / 2^b = 1/65536
q_attendu = params.A / (2^params.b);
r2 = (abs(resultats.q - q_attendu) < 1e-15);
nb_ok = nb_ok + r2;
fprintf('Cas 2  : q = %.4e V (attendu %.4e)               -> %s\n', resultats.q, q_attendu, iif(r2,'OK','ECHEC'));

%% Cas 3 : SNR = 91.89 dB >= 90 dB (cahier des charges respecte)
r3 = (resultats.SNR >= 90);
nb_ok = nb_ok + r3;
fprintf('Cas 3  : SNR = %.2f dB >= 90 dB                     -> %s\n', resultats.SNR, iif(r3,'OK','ECHEC'));

%% Cas 4 : Compatible CD = true (Fe=44100, b=16, stockage<700)
r4 = (resultats.compatible_cd == true);
nb_ok = nb_ok + r4;
fprintf('Cas 4  : compatible_cd = %d (attendu 1)              -> %s\n', resultats.compatible_cd, iif(r4,'OK','ECHEC'));

%% Cas 5 : Timbre respecte = true (Fe/2=22050 >= 20000)
r5 = (resultats.timbre_ok == true);
nb_ok = nb_ok + r5;
fprintf('Cas 5  : timbre_ok = %d (attendu 1)                  -> %s\n', resultats.timbre_ok, iif(r5,'OK','ECHEC'));

% =============================================
%  PARTIE B — CAS NEGATIFS (parametres degrades)
% =============================================
fprintf('\n--- Partie B : Cas negatifs (parametres degrades) ---\n');

%% Cas 6 : b=8 bits -> SNR trop faible (< 90 dB)
%    Avec b=8, q=1/256, Pe=q^2/12, SNR = 10*log10(0.030/Pe) = 43.78 dB
params_bad6 = params;
params_bad6.b = 8;
res6 = calcule_numerisation(params_bad6, 3600);
r6 = (res6.SNR < 90);  % On VEUT que ce soit < 90
nb_ok = nb_ok + r6;
fprintf('Cas 6  : b=8 -> SNR = %.2f dB < 90 dB (attendu)     -> %s\n', res6.SNR, iif(r6,'OK','ECHEC'));

%% Cas 7 : Fe=30000 Hz -> Timbre NON respecte (Fe/2=15000 < 20000)
params_bad7 = params;
params_bad7.Fe = 30000;
res7 = calcule_numerisation(params_bad7, 3600);
r7 = (res7.timbre_ok == false);  % On VEUT false
nb_ok = nb_ok + r7;
fprintf('Cas 7  : Fe=30000 -> timbre_ok = %d (attendu 0)      -> %s\n', res7.timbre_ok, iif(r7,'OK','ECHEC'));

%% Cas 8 : Duree=10h -> Stockage > 700 Mo => non compatible CD
params_long = params;
res8 = calcule_numerisation(params_long, 36000);  % 10 heures
r8 = (res8.compatible_cd == false);  % On VEUT false
nb_ok = nb_ok + r8;
fprintf('Cas 8  : duree=10h -> stockage=%.1f Mo, compatible_cd=%d (attendu 0) -> %s\n', res8.stockage_Mo, res8.compatible_cd, iif(r8,'OK','ECHEC'));

%% Cas 9 : Fe=96000, b=24 -> Non compatible CD (pas standard)
params_bad9 = params;
params_bad9.Fe = 96000;
params_bad9.b = 24;
res9 = calcule_numerisation(params_bad9, 3600);
r9 = (res9.compatible_cd == false);  % On VEUT false (Fe != 44100)
nb_ok = nb_ok + r9;
fprintf('Cas 9  : Fe=96k, b=24 -> compatible_cd = %d (attendu 0) -> %s\n', res9.compatible_cd, iif(r9,'OK','ECHEC'));

%% Cas 10 : Proportionnalite du stockage (1h vs 30min)
res30 = calcule_numerisation(params, 1800);
ratio = resultats.stockage_Mo / res30.stockage_Mo;
r10 = (abs(ratio - 2) < 0.01);
nb_ok = nb_ok + r10;
fprintf('Cas 10 : stockage(1h)/stockage(30min) = %.2f (attendu 2.00) -> %s\n', ratio, iif(r10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
fprintf('    dont 5 cas positifs et 5 cas negatifs/limites\n');
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== FIN ===\n');

function s = iif(c,a,b); if c, s=a; else s=b; end; end

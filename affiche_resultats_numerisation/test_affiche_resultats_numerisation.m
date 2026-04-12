% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_affiche_resultats_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   12 Avril 2026
%
% DESCRIPTION :
%   Script de test pour la fonction affiche_resultats_numerisation.
%   10 cas de test verifiant que la fonction s'execute sans erreur
%   pour differentes configurations de parametres et resultats.
%
% FONCTION TESTEE :
%   affiche_resultats_numerisation(params, resultats)
%
% MODIFICATIONS :
%   12/04/26 — Tests complets avec resume et valeurs numeriques
% #------------------------------------------

clear all; close all; clc;

addpath(fullfile('..','lire_parametres_numerisation'));
addpath(fullfile('..','calcule_numerisation'));

fprintf('=== Tests de affiche_resultats_numerisation ===\n\n');

nb_ok = 0;
nb_total = 10;

% --- Cas 1 : Appel nominal (parametres Hi-Fi standard) ---
try
    p1.f_min = 20; p1.f_max = 20000; p1.SNR_cible = 90;
    p1.V_max = 0.5; p1.A = 1.0; p1.P_moy = 0.030;
    p1.Fe = 44100; p1.b = 16; p1.n_canaux = 2;
    r1.q = 1.0/2^16; r1.Pe = (1.0/2^16)^2/12; r1.SNR = 91.89;
    r1.debit_mono = 705600; r1.debit_stereo = 1411200;
    r1.stockage_Mo = 605.62; r1.compatible_cd = true; r1.timbre_ok = true;
    affiche_resultats_numerisation(p1, r1);
    ok1 = true;
catch
    ok1 = false;
end
nb_ok = nb_ok + ok1;
fprintf('Cas 1  : Appel nominal Hi-Fi           -> %s\n', iif(ok1,'OK','ECHEC'));

% --- Cas 2 : SNR insuffisant ---
try
    p2 = p1; r2 = r1; r2.SNR = 80.0;
    affiche_resultats_numerisation(p2, r2);
    ok2 = true;
catch
    ok2 = false;
end
nb_ok = nb_ok + ok2;
fprintf('Cas 2  : SNR insuffisant               -> %s\n', iif(ok2,'OK','ECHEC'));

% --- Cas 3 : Non compatible CD (stockage > 700 Mo) ---
try
    p3 = p1; r3 = r1; r3.stockage_Mo = 800.0; r3.compatible_cd = false;
    affiche_resultats_numerisation(p3, r3);
    ok3 = true;
catch
    ok3 = false;
end
nb_ok = nb_ok + ok3;
fprintf('Cas 3  : Non compatible CD             -> %s\n', iif(ok3,'OK','ECHEC'));

% --- Cas 4 : Timbre non respecte ---
try
    p4 = p1; p4.Fe = 30000; r4 = r1; r4.timbre_ok = false;
    affiche_resultats_numerisation(p4, r4);
    ok4 = true;
catch
    ok4 = false;
end
nb_ok = nb_ok + ok4;
fprintf('Cas 4  : Timbre non respecte           -> %s\n', iif(ok4,'OK','ECHEC'));

% --- Cas 5 : Mono (1 canal) ---
try
    p5 = p1; p5.n_canaux = 1;
    r5 = r1; r5.debit_stereo = 705600; r5.stockage_Mo = 302.8;
    affiche_resultats_numerisation(p5, r5);
    ok5 = true;
catch
    ok5 = false;
end
nb_ok = nb_ok + ok5;
fprintf('Cas 5  : Mono (1 canal)                -> %s\n', iif(ok5,'OK','ECHEC'));

% --- Cas 6 : Haute resolution (b=24, Fe=96000) ---
try
    p6 = p1; p6.Fe = 96000; p6.b = 24;
    r6 = r1; r6.q = 1.0/2^24; r6.SNR = 140.0;
    r6.debit_mono = 2304000; r6.debit_stereo = 4608000;
    r6.stockage_Mo = 1976.0; r6.compatible_cd = false;
    affiche_resultats_numerisation(p6, r6);
    ok6 = true;
catch
    ok6 = false;
end
nb_ok = nb_ok + ok6;
fprintf('Cas 6  : Haute resolution 24/96        -> %s\n', iif(ok6,'OK','ECHEC'));

% --- Cas 7 : Qualite telephone (b=8, Fe=8000) ---
try
    p7 = p1; p7.Fe = 8000; p7.b = 8; p7.f_max = 3400;
    r7 = r1; r7.q = 1.0/256; r7.SNR = 43.8;
    r7.debit_mono = 64000; r7.debit_stereo = 128000;
    r7.stockage_Mo = 54.9; r7.compatible_cd = false; r7.timbre_ok = false;
    affiche_resultats_numerisation(p7, r7);
    ok7 = true;
catch
    ok7 = false;
end
nb_ok = nb_ok + ok7;
fprintf('Cas 7  : Qualite telephone 8/8000      -> %s\n', iif(ok7,'OK','ECHEC'));

% --- Cas 8 : Toutes verifications echouent ---
try
    p8 = p1; p8.Fe = 30000; p8.b = 8;
    r8 = r1; r8.SNR = 40.0; r8.compatible_cd = false; r8.timbre_ok = false;
    affiche_resultats_numerisation(p8, r8);
    ok8 = true;
catch
    ok8 = false;
end
nb_ok = nb_ok + ok8;
fprintf('Cas 8  : Toutes verifications NON      -> %s\n', iif(ok8,'OK','ECHEC'));

% --- Cas 9 : Toutes verifications OK ---
try
    p9 = p1;
    r9 = r1; r9.SNR = 95.0; r9.compatible_cd = true; r9.timbre_ok = true;
    affiche_resultats_numerisation(p9, r9);
    ok9 = true;
catch
    ok9 = false;
end
nb_ok = nb_ok + ok9;
fprintf('Cas 9  : Toutes verifications OK       -> %s\n', iif(ok9,'OK','ECHEC'));

% --- Cas 10 : Chaine complete (lire -> calcule -> affiche) ---
try
    p10 = lire_parametres_numerisation();
    r10 = calcule_numerisation(p10, 3600);
    affiche_resultats_numerisation(p10, r10);
    ok10 = true;
catch
    ok10 = false;
end
nb_ok = nb_ok + ok10;
fprintf('Cas 10 : Chaine complete E->C->S       -> %s\n', iif(ok10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== Fin des tests ===\n');

% --- Fonction utilitaire ---
function s = iif(c, a, b)
    if c, s = a; else, s = b; end
end

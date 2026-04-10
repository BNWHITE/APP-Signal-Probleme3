% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   test_affiche_resultats_numerisation
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Script de test pour la fonction affiche_resultats_numerisation.
%   Vérifie que la fonction s'exécute sans erreur pour différentes
%   configurations de paramètres et résultats.
%
% ENTREES :
%   Aucune
%
% SORTIES :
%   Aucune (affichage console des résultats de test)
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

clear all; close all; clc;

addpath(fullfile('..','lire_parametres_numerisation'));
addpath(fullfile('..','calcule_numerisation'));

fprintf('=== Tests de affiche_resultats_numerisation ===\n\n');

% --- Cas 1 : Appel nominal (paramètres Hi-Fi standard) ---
try
    p1.f_min = 20; p1.f_max = 20000; p1.SNR_cible = 90;
    p1.V_max = 0.5; p1.A = 1.0; p1.P_moy = 0.030;
    p1.Fe = 44100; p1.b = 16; p1.n_canaux = 2;
    r1.q = 1.0/2^16; r1.Pe = 0.030; r1.SNR = 91.87;
    r1.debit_mono = 705600; r1.debit_stereo = 1411200;
    r1.stockage_Mo = 605.6; r1.compatible_cd = true; r1.timbre_ok = true;
    affiche_resultats_numerisation(p1, r1);
    ok1 = true;
catch
    ok1 = false;
end
fprintf('Cas 1  : Appel nominal Hi-Fi           → %s\n', iif(ok1,'OK','ECHEC'));

% --- Cas 2 : SNR insuffisant ---
try
    p2 = p1; r2 = r1; r2.SNR = 80.0;
    affiche_resultats_numerisation(p2, r2);
    ok2 = true;
catch
    ok2 = false;
end
fprintf('Cas 2  : SNR insuffisant               → %s\n', iif(ok2,'OK','ECHEC'));

% --- Cas 3 : Non compatible CD (stockage > 700 Mo) ---
try
    p3 = p1; r3 = r1; r3.stockage_Mo = 800.0; r3.compatible_cd = false;
    affiche_resultats_numerisation(p3, r3);
    ok3 = true;
catch
    ok3 = false;
end
fprintf('Cas 3  : Non compatible CD             → %s\n', iif(ok3,'OK','ECHEC'));

% --- Cas 4 : Timbre non respecté ---
try
    p4 = p1; p4.Fe = 30000; r4 = r1; r4.timbre_ok = false;
    affiche_resultats_numerisation(p4, r4);
    ok4 = true;
catch
    ok4 = false;
end
fprintf('Cas 4  : Timbre non respecté           → %s\n', iif(ok4,'OK','ECHEC'));

% --- Cas 5 : Mono (1 canal) ---
try
    p5 = p1; p5.n_canaux = 1;
    r5 = r1; r5.debit_stereo = 705600; r5.stockage_Mo = 302.8;
    affiche_resultats_numerisation(p5, r5);
    ok5 = true;
catch
    ok5 = false;
end
fprintf('Cas 5  : Mono (1 canal)                → %s\n', iif(ok5,'OK','ECHEC'));

% --- Cas 6 : Haute résolution (b=24, Fe=96000) ---
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
fprintf('Cas 6  : Haute résolution 24/96        → %s\n', iif(ok6,'OK','ECHEC'));

% --- Cas 7 : Qualité téléphone (b=8, Fe=8000) ---
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
fprintf('Cas 7  : Qualité téléphone 8/8000      → %s\n', iif(ok7,'OK','ECHEC'));

% --- Cas 8 : Toutes vérifications échouent ---
try
    p8 = p1; p8.Fe = 30000; p8.b = 8;
    r8 = r1; r8.SNR = 40.0; r8.compatible_cd = false; r8.timbre_ok = false;
    affiche_resultats_numerisation(p8, r8);
    ok8 = true;
catch
    ok8 = false;
end
fprintf('Cas 8  : Toutes vérifications NON      → %s\n', iif(ok8,'OK','ECHEC'));

% --- Cas 9 : Toutes vérifications OK ---
try
    p9 = p1;
    r9 = r1; r9.SNR = 95.0; r9.compatible_cd = true; r9.timbre_ok = true;
    affiche_resultats_numerisation(p9, r9);
    ok9 = true;
catch
    ok9 = false;
end
fprintf('Cas 9  : Toutes vérifications OK       → %s\n', iif(ok9,'OK','ECHEC'));

% --- Cas 10 : Appel via chaîne complète (lire → calcule → affiche) ---
try
    p10 = lire_parametres_numerisation();
    r10 = calcule_numerisation(p10, 3600);
    affiche_resultats_numerisation(p10, r10);
    ok10 = true;
catch
    ok10 = false;
end
fprintf('Cas 10 : Chaîne complète E→C→S         → %s\n', iif(ok10,'OK','ECHEC'));

fprintf('\n=== Fin des tests ===\n');

% --- Fonction utilitaire ---
function s = iif(c, a, b)
    if c, s = a; else, s = b; end
end

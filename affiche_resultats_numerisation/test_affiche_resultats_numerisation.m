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
%   et affiche correctement les resultats pour differentes
%   configurations :
%     - Cas nominaux (tout [OK])
%     - Cas degrades (un ou plusieurs [NON])
%     - Cas limites (telephone, haute resolution)
%     - Chaine complete (lire -> calcule -> affiche)
%
% FONCTION TESTEE :
%   affiche_resultats_numerisation(params, resultats)
%
% MODIFICATIONS :
%   12/04/26 — Version finale avec cas positifs et negatifs
% #------------------------------------------

clear all; close all; clc;

addpath(fullfile('..','lire_parametres_numerisation'));
addpath(fullfile('..','calcule_numerisation'));

fprintf('=== Tests de affiche_resultats_numerisation ===\n\n');

nb_ok = 0;
nb_total = 10;

%% Construction des parametres de base Hi-Fi
p_hifi.f_min = 20; p_hifi.f_max = 20000; p_hifi.SNR_cible = 90;
p_hifi.V_max = 0.5; p_hifi.A = 1.0; p_hifi.P_moy = 0.030;
p_hifi.Fe = 44100; p_hifi.b = 16; p_hifi.n_canaux = 2;

% =============================================
%  PARTIE A — CAS POSITIFS (tout [OK])
% =============================================
fprintf('--- Partie A : Cas positifs ---\n');

%% Cas 1 : Appel nominal Hi-Fi — tout doit etre [OK]
try
    r_hifi = calcule_numerisation(p_hifi, 3600);
    affiche_resultats_numerisation(p_hifi, r_hifi);
    ok1 = true;
catch
    ok1 = false;
end
nb_ok = nb_ok + ok1;
fprintf('Cas 1  : Appel nominal Hi-Fi (3x[OK])      -> %s\n', iif(ok1,'OK','ECHEC'));

%% Cas 2 : Chaine complete lire -> calcule -> affiche
try
    p2 = lire_parametres_numerisation();
    r2 = calcule_numerisation(p2, 3600);
    affiche_resultats_numerisation(p2, r2);
    ok2 = true;
catch
    ok2 = false;
end
nb_ok = nb_ok + ok2;
fprintf('Cas 2  : Chaine complete E->C->S (3x[OK])  -> %s\n', iif(ok2,'OK','ECHEC'));

%% Cas 3 : Mono (1 canal) — doit marcher sans erreur
try
    p3 = p_hifi; p3.n_canaux = 1;
    r3 = calcule_numerisation(p3, 3600);
    affiche_resultats_numerisation(p3, r3);
    ok3 = true;
catch
    ok3 = false;
end
nb_ok = nb_ok + ok3;
fprintf('Cas 3  : Mono (1 canal)                    -> %s\n', iif(ok3,'OK','ECHEC'));

% =============================================
%  PARTIE B — CAS NEGATIFS (un ou plusieurs [NON])
% =============================================
fprintf('\n--- Partie B : Cas negatifs (verifs [NON]) ---\n');

%% Cas 4 : SNR insuffisant (b=8 -> SNR=43.78 dB < 90 dB) -> [NON] SNR
try
    p4 = p_hifi; p4.b = 8;
    r4 = calcule_numerisation(p4, 3600);
    affiche_resultats_numerisation(p4, r4);
    ok4 = (r4.SNR < 90);  % Verification : le SNR est bien < 90
catch
    ok4 = false;
end
nb_ok = nb_ok + ok4;
fprintf('Cas 4  : b=8 -> SNR=%.1f dB [NON attendu]  -> %s\n', r4.SNR, iif(ok4,'OK','ECHEC'));

%% Cas 5 : Timbre non respecte (Fe=30000, Fe/2=15000 < 20000)
try
    p5 = p_hifi; p5.Fe = 30000;
    r5 = calcule_numerisation(p5, 3600);
    affiche_resultats_numerisation(p5, r5);
    ok5 = (r5.timbre_ok == false);  % Verification : timbre doit etre false
catch
    ok5 = false;
end
nb_ok = nb_ok + ok5;
fprintf('Cas 5  : Fe=30000 -> timbre [NON attendu]  -> %s\n', iif(ok5,'OK','ECHEC'));

%% Cas 6 : Non compatible CD (duree=10h -> stockage > 700 Mo)
try
    p6 = p_hifi;
    r6 = calcule_numerisation(p6, 36000);  % 10 heures
    affiche_resultats_numerisation(p6, r6);
    ok6 = (r6.compatible_cd == false);  % Verification
catch
    ok6 = false;
end
nb_ok = nb_ok + ok6;
fprintf('Cas 6  : 10h -> %.0f Mo, CD [NON attendu]  -> %s\n', r6.stockage_Mo, iif(ok6,'OK','ECHEC'));

%% Cas 7 : Tout echoue (b=8, Fe=30000, duree=10h)
try
    p7 = p_hifi; p7.b = 8; p7.Fe = 30000;
    r7 = calcule_numerisation(p7, 36000);
    affiche_resultats_numerisation(p7, r7);
    ok7 = (r7.SNR < 90) && (~r7.compatible_cd) && (~r7.timbre_ok);
catch
    ok7 = false;
end
nb_ok = nb_ok + ok7;
fprintf('Cas 7  : Tout degrade -> 3x[NON attendu]   -> %s\n', iif(ok7,'OK','ECHEC'));

% =============================================
%  PARTIE C — CAS LIMITES
% =============================================
fprintf('\n--- Partie C : Cas limites ---\n');

%% Cas 8 : Haute resolution (24 bits / 96 kHz) -> SNR tres eleve, CD [NON]
try
    p8 = p_hifi; p8.Fe = 96000; p8.b = 24;
    r8 = calcule_numerisation(p8, 3600);
    affiche_resultats_numerisation(p8, r8);
    ok8 = (r8.SNR > 90) && (r8.compatible_cd == false);
catch
    ok8 = false;
end
nb_ok = nb_ok + ok8;
fprintf('Cas 8  : 24b/96kHz -> SNR=%.0f, CD [NON]   -> %s\n', r8.SNR, iif(ok8,'OK','ECHEC'));

%% Cas 9 : Qualite telephone (8 bits / 8 kHz / f_max=3400)
try
    p9 = p_hifi; p9.Fe = 8000; p9.b = 8; p9.f_max = 3400;
    r9 = calcule_numerisation(p9, 3600);
    affiche_resultats_numerisation(p9, r9);
    ok9 = (r9.SNR < 90) && (r9.compatible_cd == false);
catch
    ok9 = false;
end
nb_ok = nb_ok + ok9;
fprintf('Cas 9  : Telephone 8b/8kHz -> SNR=%.1f, CD [NON] -> %s\n', r9.SNR, iif(ok9,'OK','ECHEC'));

%% Cas 10 : Duree courte (1 min) — doit fonctionner, stockage tres petit
try
    p10 = p_hifi;
    r10 = calcule_numerisation(p10, 60);  % 1 minute
    affiche_resultats_numerisation(p10, r10);
    ok10 = (r10.stockage_Mo < 20) && (r10.compatible_cd == true);
catch
    ok10 = false;
end
nb_ok = nb_ok + ok10;
fprintf('Cas 10 : 1 min -> %.2f Mo, CD [OK]          -> %s\n', r10.stockage_Mo, iif(ok10,'OK','ECHEC'));

%% Resume
fprintf('\n--- Resume : %d / %d cas reussis ---\n', nb_ok, nb_total);
fprintf('    dont 3 positifs, 4 negatifs, 3 limites\n');
if nb_ok == nb_total
    fprintf('>>> TOUS LES TESTS PASSENT <<<\n');
else
    fprintf('>>> %d TEST(S) EN ECHEC <<<\n', nb_total - nb_ok);
end
fprintf('\n=== Fin des tests ===\n');

function s = iif(c, a, b)
    if c, s = a; else, s = b; end
end

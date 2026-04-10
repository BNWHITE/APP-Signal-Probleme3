% #------------------------------------------
% NOM DU SCRIPT / FONCTION :
%   main
%
% AUTEUR :
%   G2D
%
% DATE :
%   11 Avril 2026
%
% DESCRIPTION :
%   Script principal du Problème III — Numérisation audio Hi-Fi.
%   Appelle les 3 fonctions dans l'ordre :
%     1. Entrée  : lire_parametres_numerisation
%     2. Calcul  : calcule_numerisation
%     3. Sortie  : affiche_resultats_numerisation
%
% ENTREES :
%   Aucune
%
% SORTIES :
%   Aucune (affichage console)
%
% MODIFICATIONS :
%   Aucune
% #------------------------------------------

clear all; close all; clc;

%% Ajout des chemins
addpath('lire_parametres_numerisation');
addpath('calcule_numerisation');
addpath('affiche_resultats_numerisation');

%% 1. ENTREE — Lecture des paramètres de numérisation
params = lire_parametres_numerisation();

%% 2. CALCUL — Calcul des grandeurs de numérisation
duree = 3600;       % 1 heure de concert en secondes
resultats = calcule_numerisation(params, duree);

%% 3. SORTIE — Affichage des résultats
affiche_resultats_numerisation(params, resultats);

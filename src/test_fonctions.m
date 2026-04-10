%% TEST_FONCTIONS.m - Appel des 3 fonctions : Lecture → Calcul → Sortie
clear; clc;

%% 1. LECTURE (rien en entrée → valeurs en sortie)
[Fe, b, A, P_moy, n_canaux] = fonction_lecture();

%% 2. CALCUL (valeurs en entrée → valeurs en sortie)
[SNR, debit, stockage_Mo] = fonction_calcul(Fe, b, A, P_moy, n_canaux);

%% 3. SORTIE (valeurs en entrée → rien en sortie)
fonction_sortie(SNR, debit, stockage_Mo);

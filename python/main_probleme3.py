"""
==========================================================================
 MAIN_PROBLEME3.py - Script principal : Résolution du Problème III
 APP Signal - ISEP 2025-2026
 
 Problème : Enregistrement numérique haute fidélité
 - Bande de fréquences : 20 Hz à 20 000 Hz
 - SNR moyen : 90 dB
 - Micro idéal, dynamique [-500 mV, +500 mV]
 - Puissance moyenne en sortie : 30 mW
==========================================================================
"""

import numpy as np
import matplotlib.pyplot as plt
from parametres_numerisation import ParametresNumerisation
from filtre_anti_repliement import concevoir_filtre
from simulation_quantification import simulation_quantification

def main():
    print("=" * 60)
    print("  PROBLÈME III : Numérisation d'un signal audio Hi-Fi")
    print("=" * 60)
    
    # ---- 1. PARAMÈTRES DU PROBLÈME ----
    print("\n--- 1. Paramètres du problème ---")
    params = ParametresNumerisation(
        f_min=20,           # Hz
        f_max=20000,        # Hz
        SNR_cible=90,       # dB
        V_max=0.5,          # V (amplitude crête)
        P_moy=30e-3,        # W
        n_canaux=2          # stéréo
    )
    params.afficher_donnees()
    
    # ---- 2. SCHÉMA FONCTIONNEL ----
    print("\n--- 2. Schéma fonctionnel de numérisation ---")
    print("  Micro → Filtre anti-repliement → Échantillonneur → Quantificateur → Signal numérique")
    print("          (passe-bas, fc < Fe/2)    (fréquence Fe)     (b bits)")
    
    # ---- 3. FRÉQUENCE D'ÉCHANTILLONNAGE ----
    print("\n--- 3. Fréquence d'échantillonnage ---")
    params.calculer_frequence_echantillonnage()
    
    # ---- 4. NOMBRE DE BITS ----
    print("\n--- 4. Nombre de bits de quantification ---")
    params.calculer_nombre_bits()
    
    # ---- 5. DÉBIT ET STOCKAGE ----
    print("\n--- 5. Débit et stockage ---")
    params.calculer_debit_stockage()
    
    # ---- 6. COMPATIBILITÉ CD ----
    print("\n--- 6. Compatibilité CD ---")
    params.verifier_compatibilite_cd()
    
    # ---- 7. TIMBRE DES INSTRUMENTS ----
    print("\n--- 7. Timbre des instruments ---")
    params.analyser_timbre()
    
    # ---- 8. RÉCAPITULATIF ----
    params.afficher_recapitulatif()
    
    # ---- 9. SIMULATION QUANTIFICATION ----
    print("\n--- 9. Simulation de la quantification ---")
    simulation_quantification(Fe=params.Fe, V_max=params.V_max, b_max=20)
    
    # ---- 10. FILTRE ANTI-REPLIEMENT ----
    print("\n--- 10. Filtre anti-repliement ---")
    concevoir_filtre(Fe=params.Fe, f_pass=params.f_max, f_stop=params.Fe // 2)
    
    print("\n✓ Tous les résultats ont été générés avec succès !")
    print("  Les figures sont sauvegardées dans le dossier ../figures/")
    
    plt.show()


if __name__ == "__main__":
    main()

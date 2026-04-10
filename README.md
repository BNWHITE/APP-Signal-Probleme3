# APP Signal — Problème III : Numérisation audio haute fidélité

## 📋 Énoncé

Enregistrement numérique Hi-Fi :
- Bande : **[20 Hz, 20 000 Hz]**, SNR ≥ **90 dB**
- Micro idéal, dynamique **[-500 mV, +500 mV]**, P_moy = **30 mW**

## 📁 Structure du projet

```
APP-Signal-Probleme3/
├── main.m                                          # Script principal (E → C → S)
├── README.md
├── .gitignore
│
├── lire_parametres_numerisation/                   # ENTRÉE
│   ├── lire_parametres_numerisation.m              # Fonction (pas d'entrée → params)
│   ├── test_lire_parametres_numerisation.m         # 10 cas de test
│   ├── fiche-test-lire_parametres_numerisation.txt # Fiche de tests
│   └── fiche-test-lire_parametres_numerisation.xlsx
│
├── calcule_numerisation/                           # CALCUL
│   ├── calcule_numerisation.m                      # Fonction (params, durée → résultats)
│   ├── test_calcule_numerisation.m                 # 10 cas de test
│   ├── fiche-test-calcule_numerisation.txt         # Fiche de tests
│   └── fiche-test-calcule_numerisation.xlsx
│
└── affiche_resultats_numerisation/                 # SORTIE
    ├── affiche_resultats_numerisation.m            # Fonction (params, résultats → affichage)
    ├── test_affiche_resultats_numerisation.m       # 10 cas de test
    ├── fiche-test-affiche_resultats_numerisation.txt
    └── fiche-test-affiche_resultats_numerisation.xlsx
```

## 🚀 Utilisation

```matlab
% Depuis la racine du projet :
main
```

Ou pour exécuter les tests d'un module :
```matlab
cd lire_parametres_numerisation
test_lire_parametres_numerisation

cd ../calcule_numerisation
test_calcule_numerisation

cd ../affiche_resultats_numerisation
test_affiche_resultats_numerisation
```

## 📐 Résultats attendus

| Paramètre | Valeur |
|---|---|
| Fe | 44 100 Hz |
| b | 16 bits |
| SNR | ≈ 91.9 dB |
| Débit stéréo | 1 411.2 kbits/s |
| Stockage 1h | ≈ 605.6 Mo |
| Compatible CD | ✅ |
| Timbre OK | ✅ |

## 👥 Auteurs
- Groupe **G2D**
- Date : 2025-2026

## 📚 Références
- APP A1 Composante Signal 2025-2026 — V3
- Consignes rapport 2025-2026

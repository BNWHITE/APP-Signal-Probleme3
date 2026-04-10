# APP Signal - Problème III : Numérisation d'un signal audio haute fidélité

## 📋 Énoncé du problème

On souhaite effectuer un **enregistrement numérique en haute fidélité**, avec :
- Bande de fréquences : **20 Hz à 20 000 Hz**
- Rapport signal à bruit moyen : **90 dB**
- Micro idéal (bande infinie, aucune distorsion, aucun bruit)
- Dynamique du micro : **[-500 mV, +500 mV]**
- Puissance moyenne en sortie du micro : **30 mW**

### Objectifs
1. Donner le **schéma fonctionnel** de numérisation du signal
2. Déterminer **tous les paramètres** (Fe, b, filtre anti-repliement...)
3. Calculer le **débit** du signal numérique
4. Calculer la **capacité de stockage** pour 1h de concert stéréo
5. Vérifier la **compatibilité CD** (44.1 kHz, 16 bits)
6. Vérifier si les paramètres respectent le **timbre des instruments** d'un orchestre symphonique

---

## 📁 Structure du projet

```
APP-Signal-Probleme3/
├── README.md                          # Ce fichier
├── src/                               # Scripts MATLAB
│   ├── main_probleme3.m               # Script principal - résolution complète
│   ├── schema_numerisation.m          # Schéma fonctionnel de la chaîne
│   ├── calcul_parametres.m            # Calcul de Fe, b, q, débit
│   ├── filtre_anti_repliement.m       # Conception du filtre anti-repliement
│   ├── simulation_quantification.m    # Simulation de la quantification + SNR
│   ├── comparaison_cd.m               # Comparaison avec le standard CD
│   ├── analyse_timbre.m               # Analyse du timbre des instruments
│   └── utils/
│       ├── calcul_snr.m               # Fonction utilitaire SNR
│       ├── afficher_spectre.m         # Affichage spectral
│       └── generer_signal_test.m      # Génération de signaux de test
├── python/                            # Scripts Python (alternatives)
│   ├── main_probleme3.py              # Script principal Python
│   ├── parametres_numerisation.py     # Calcul des paramètres
│   ├── filtre_anti_repliement.py      # Conception du filtre
│   ├── simulation_quantification.py   # Simulation quantification
│   └── utils.py                       # Fonctions utilitaires
├── rapport/                           # Rapport LaTeX
│   ├── rapport_probleme3.tex          # Fichier principal du rapport
│   ├── references.bib                 # Bibliographie
│   └── figures/                       # Figures pour le rapport
├── figures/                           # Figures générées par les scripts
└── data/                              # Signaux de test
```

---

## 🚀 Utilisation

### MATLAB
```matlab
% Exécuter le script principal
cd src
main_probleme3
```

### Python
```bash
cd python
pip install numpy scipy matplotlib
python main_probleme3.py
```

### Rapport LaTeX
```bash
cd rapport
pdflatex rapport_probleme3.tex
bibtex rapport_probleme3
pdflatex rapport_probleme3.tex
pdflatex rapport_probleme3.tex
```

---

## 📐 Rappels théoriques

### Théorème de Shannon
Fe ≥ 2 × fmax

### Bruit de quantification
Pe = q² / 12, avec q = A / 2^b

### SNR de quantification
SNR(dB) ≈ 6.02 × b + 1.76 dB (pour un signal sinusoïdal pleine échelle)

### Débit binaire
D = Fe × b × nombre_de_canaux (bits/s)

---

## 👥 Auteurs
- Groupe : [Numéro de groupe]
- Membres : [Noms des membres]
- Tuteur : [Nom du tuteur]
- Date : 2025-2026

## 📚 Références
- APP A1 Composante Signal 2025-2026 - V3
- Consignes rapport 2025-2026

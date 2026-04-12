# Guide d'utilisateur — Problème III : Numérisation audio Hi-Fi

**Groupe G2D — APP Signal 2025-2026 — ISEP**  
**Date** : 12 Avril 2026

---

## 1. Présentation du projet

Ce programme MATLAB réalise l'étude complète de la **numérisation d'un signal audio haute fidélité** (concert d'orchestre symphonique). Il détermine les paramètres de numérisation (fréquence d'échantillonnage, nombre de bits) à partir du cahier des charges, puis calcule les grandeurs associées (pas de quantification, SNR, débit, stockage) et affiche un bilan complet avec vérifications.

### Cahier des charges

| Paramètre | Valeur |
|---|---|
| Bande de fréquences | [20 Hz, 20 000 Hz] |
| SNR cible | ≥ 90 dB |
| Dynamique micro | [-500 mV, +500 mV] |
| Puissance moyenne du signal | 30 mW |
| Mode | Stéréo (2 canaux) |
| Durée d'enregistrement | 1 heure |

---

## 2. Prérequis

- **MATLAB R2023a** ou version ultérieure (ou **GNU Octave** ≥ 6.0)
- Aucune toolbox supplémentaire requise
- Système d'exploitation : Windows, macOS ou Linux

---

## 3. Structure du projet

```
APP-Signal-Probleme3/
│
├── main.m                              ← Script principal (point d'entrée)
├── guide_utilisateur.md                ← Ce fichier
├── run_all_tests.sh                    ← Lance tous les tests automatiquement
│
├── lire_parametres_numerisation/
│   ├── lire_parametres_numerisation.m  ← Fonction : lecture des paramètres
│   ├── test_lire_parametres_numerisation.m
│   ├── fiche-test-lire_parametres_numerisation.xlsx
│   └── fiche-test-lire_parametres_numerisation.txt
│
├── calcule_numerisation/
│   ├── calcule_numerisation.m          ← Fonction : calculs de numérisation
│   ├── test_calcule_numerisation.m
│   ├── fiche-test-calcule_numerisation.xlsx
│   └── fiche-test-calcule_numerisation.txt
│
└── affiche_resultats_numerisation/
    ├── affiche_resultats_numerisation.m ← Fonction : affichage des résultats
    ├── test_affiche_resultats_numerisation.m
    ├── fiche-test-affiche_resultats_numerisation.xlsx
    └── fiche-test-affiche_resultats_numerisation.txt
```

---

## 4. Installation et mise en route

### 4.1 Récupérer le projet

```bash
git clone https://github.com/BNWHITE/APP-Signal-Probleme3.git
cd APP-Signal-Probleme3
```

### 4.2 Exécuter le programme principal

1. Ouvrir **MATLAB**
2. Se placer dans le dossier `APP-Signal-Probleme3`
3. Exécuter dans la console :

```matlab
main
```

Le programme va :
1. **Lire** les paramètres du cahier des charges
2. **Calculer** toutes les grandeurs de numérisation
3. **Afficher** un bilan complet avec vérifications

### 4.3 Résultat attendu

L'affichage en console contient :
- Un **schéma fonctionnel** de la chaîne de numérisation
- Un **tableau récapitulatif** des paramètres et résultats
- Des **vérifications** automatiques :
  - `[OK] SNR = 91.89 dB ≥ 90 dB`
  - `[OK] Compatible CD (605.62 Mo ≤ 700 Mo)`
  - `[OK] Timbre respecté (Fe/2 = 22050 Hz ≥ 20000 Hz)`

---

## 5. Description des fonctions

### 5.1 `lire_parametres_numerisation()`

| | |
|---|---|
| **Fichier** | `lire_parametres_numerisation/lire_parametres_numerisation.m` |
| **Entrées** | Aucune |
| **Sortie** | `params` — structure MATLAB |
| **Rôle** | Initialise tous les paramètres du cahier des charges et calcule b (nombre de bits) nécessaire pour atteindre le SNR cible |

**Champs de la structure `params` :**

| Champ | Type | Valeur | Description |
|---|---|---|---|
| `f_min` | double | 20 | Fréquence minimale (Hz) |
| `f_max` | double | 20 000 | Fréquence maximale (Hz) |
| `SNR_cible` | double | 90 | SNR cible (dB) |
| `V_max` | double | 0.5 | Tension crête micro (V) |
| `A` | double | 1 | Dynamique totale (V) |
| `P_moy` | double | 0.030 | Puissance moyenne (W) |
| `Fe` | double | 44 100 | Fréquence d'échantillonnage (Hz) |
| `b` | double | 16 | Nombre de bits |
| `n_canaux` | double | 2 | Nombre de canaux (stéréo) |

### 5.2 `calcule_numerisation(params, duree)`

| | |
|---|---|
| **Fichier** | `calcule_numerisation/calcule_numerisation.m` |
| **Entrées** | `params` (structure), `duree` (double, en secondes) |
| **Sortie** | `resultats` — structure MATLAB |
| **Rôle** | Calcule les grandeurs de numérisation |

**Champs de la structure `resultats` :**

| Champ | Type | Formule | Valeur (Hi-Fi, 1h) |
|---|---|---|---|
| `q` | double | A / 2^b | 1.5259×10⁻⁵ V |
| `Pe` | double | q² / 12 | 1.9403×10⁻¹¹ W |
| `SNR` | double | 10×log₁₀(P_moy / Pe) | 91.89 dB |
| `debit_mono` | double | Fe × b | 705 600 bits/s |
| `debit_stereo` | double | debit_mono × n_canaux | 1 411 200 bits/s |
| `stockage_Mo` | double | debit_stereo × duree / 8 / 1024² | 605.62 Mo |
| `compatible_cd` | logical | Fe==44100 ∧ b≤16 ∧ stockage≤700 | true |
| `timbre_ok` | logical | Fe/2 ≥ f_max | true |

### 5.3 `affiche_resultats_numerisation(params, resultats)`

| | |
|---|---|
| **Fichier** | `affiche_resultats_numerisation/affiche_resultats_numerisation.m` |
| **Entrées** | `params` (structure), `resultats` (structure) |
| **Sortie** | Aucune (affichage console) |
| **Rôle** | Affiche le schéma fonctionnel, le tableau des résultats et les vérifications [OK] / [NON] |

---

## 6. Exécuter les tests

### 6.1 Depuis MATLAB

Exécuter chaque script de test individuellement :

```matlab
cd lire_parametres_numerisation
test_lire_parametres_numerisation
cd ../calcule_numerisation
test_calcule_numerisation
cd ../affiche_resultats_numerisation
test_affiche_resultats_numerisation
```

Chaque test affiche un résumé du type :
```
=== BILAN : 10 / 10 tests réussis ===
```

### 6.2 Depuis le terminal (Octave)

Un script shell est fourni pour lancer tous les tests d'un coup :

```bash
chmod +x run_all_tests.sh
./run_all_tests.sh          # Mode Octave (par défaut)
./run_all_tests.sh matlab   # Mode MATLAB
```

### 6.3 Contenu des tests

| Module | Nb tests | Positifs | Négatifs | Limites |
|---|---|---|---|---|
| `lire_parametres_numerisation` | 10 | 10 | — | — |
| `calcule_numerisation` | 10 | 5 | 5 | — |
| `affiche_resultats_numerisation` | 10 | 3 | 4 | 3 |
| **Total** | **30** | **18** | **9** | **3** |

**Exemples de cas négatifs testés :**
- `b = 8 bits` → SNR = 43.78 dB < 90 dB (insuffisant)
- `Fe = 30000 Hz` → Fe/2 = 15000 Hz < 20000 Hz (timbre non respecté)
- `durée = 10h` → stockage = 6056 Mo > 700 Mo (non compatible CD)
- `b=8, Fe=30000, durée=10h` → tout échoue simultanément

---

## 7. Fiches de test

Les fiches de test sont disponibles en **format Excel** (`.xlsx`) dans chaque sous-dossier :

| Fiche | Fichier |
|---|---|
| FT-PIII-01 | `lire_parametres_numerisation/fiche-test-lire_parametres_numerisation.xlsx` |
| FT-PIII-02 | `calcule_numerisation/fiche-test-calcule_numerisation.xlsx` |
| FT-PIII-03 | `affiche_resultats_numerisation/fiche-test-affiche_resultats_numerisation.xlsx` |

Chaque fiche contient :
- **En-tête** : ID, module, groupe, date
- **Conditions préalables**
- **Tableau des scénarios** : N°, Description, Données, Action, Attendu, Obtenu, Statut
- **Sections** : Cas positifs, cas négatifs, cas limites (selon le module)
- **Journal testeur** : date, testeur, bilan global

---

## 8. Formules utilisées

### Pas de quantification
$$q = \frac{A}{2^b}$$

### Puissance du bruit de quantification
$$P_e = \frac{q^2}{12}$$

### Rapport signal sur bruit (SNR)
$$SNR = 10 \cdot \log_{10}\left(\frac{P_{moy}}{P_e}\right)$$

### Nombre de bits minimal
$$b_{min} = \left\lceil \frac{SNR_{cible} - 10 \cdot \log_{10}\left(\frac{12 \cdot P_{moy}}{A^2}\right)}{20 \cdot \log_{10}(2)} \right\rceil$$

### Débit binaire
$$D_{mono} = F_e \times b \quad ; \quad D_{stéréo} = D_{mono} \times n_{canaux}$$

### Volume de stockage
$$V_{Mo} = \frac{D_{stéréo} \times durée}{8 \times 1024^2}$$

---

## 9. Résultats numériques de référence

| Grandeur | Valeur |
|---|---|
| q | 1.5259 × 10⁻⁵ V |
| Pe | 1.9403 × 10⁻¹¹ W |
| SNR | 91.89 dB |
| Débit mono | 705 600 bits/s |
| Débit stéréo | 1 411 200 bits/s |
| Stockage (1h stéréo) | 605.62 Mo |
| Compatible CD | Oui ✓ |
| Timbre respecté | Oui ✓ |

---

## 10. Dépannage

| Problème | Solution |
|---|---|
| `Undefined function 'lire_parametres_numerisation'` | Exécuter `main.m` qui ajoute les chemins, ou lancer `addpath('lire_parametres_numerisation')` manuellement |
| `Not enough input arguments` | Vérifier que vous passez bien les 2 arguments à `calcule_numerisation(params, duree)` |
| Les tests affichent `ECHEC` | Vérifier la version de MATLAB (≥ R2023a) et que les fonctions n'ont pas été modifiées |
| Les fichiers Excel ne s'ouvrent pas | Installer un tableur compatible (Excel, LibreOffice Calc, Google Sheets) |

---

*Document généré pour le Problème III — APP Signal — ISEP 2025-2026*

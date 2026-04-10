"""
==========================================================================
 UTILS.py - Fonctions utilitaires
 APP Signal - ISEP 2025-2026 - Problème III
==========================================================================
"""

import numpy as np


def calcul_snr_db(x, x_q):
    """
    Calcule le rapport signal à bruit (SNR) en dB.
    
    x   : signal original
    x_q : signal quantifié
    
    Retourne : SNR en dB
    """
    e = x - x_q
    P_signal = np.mean(x**2)
    P_erreur = np.mean(e**2)
    
    if P_erreur > 0:
        return 10 * np.log10(P_signal / P_erreur)
    return np.inf


def snr_theorique_sinus(b):
    """
    SNR théorique pour un signal sinusoïdal pleine échelle quantifié sur b bits.
    
    Retourne : SNR en dB
    """
    return 6.02 * b + 1.76


def snr_theorique_general(P_moy, A, b):
    """
    SNR théorique de quantification pour un signal quelconque.
    
    P_moy : puissance moyenne du signal (W)
    A     : dynamique totale (V)
    b     : nombre de bits
    
    Retourne : SNR en dB
    """
    q = A / (2**b)
    Pe = q**2 / 12
    return 10 * np.log10(P_moy / Pe)


def puissance_dbm(P_watts):
    """Convertit une puissance en Watts en dBm."""
    return 10 * np.log10(P_watts / 1e-3)


def puissance_dbw(P_watts):
    """Convertit une puissance en Watts en dBW."""
    return 10 * np.log10(P_watts)


def debit_binaire(Fe, b, n_canaux=1):
    """
    Calcule le débit binaire d'un signal numérique.
    
    Fe       : fréquence d'échantillonnage (Hz)
    b        : nombre de bits par échantillon
    n_canaux : nombre de canaux (1=mono, 2=stéréo)
    
    Retourne : débit en bits/s
    """
    return Fe * b * n_canaux


def stockage_octets(debit_bps, duree_s):
    """
    Calcule le volume de stockage en octets.
    
    debit_bps : débit en bits/s
    duree_s   : durée en secondes
    
    Retourne : volume en octets
    """
    return debit_bps * duree_s / 8


def octets_vers_mo(volume_octets):
    """Convertit un volume en octets en Mo."""
    return volume_octets / (1024**2)


def generer_sinus(f0, A, Fe, duree):
    """
    Génère un signal sinusoïdal.
    
    f0    : fréquence (Hz)
    A     : amplitude crête (V)
    Fe    : fréquence d'échantillonnage (Hz)
    duree : durée (s)
    
    Retourne : (signal, vecteur temps)
    """
    t = np.arange(0, duree, 1 / Fe)
    x = A * np.sin(2 * np.pi * f0 * t)
    return x, t


def generer_multi_harmoniques(f0, A, Fe, duree, n_harm=10):
    """
    Génère un signal riche en harmoniques (simulation de timbre).
    
    f0     : fréquence fondamentale (Hz)
    A      : amplitude crête (V)
    Fe     : fréquence d'échantillonnage (Hz)
    duree  : durée (s)
    n_harm : nombre d'harmoniques
    
    Retourne : (signal, vecteur temps)
    """
    t = np.arange(0, duree, 1 / Fe)
    f_max = Fe / 2
    
    x = np.zeros_like(t)
    for k in range(1, n_harm + 1):
        if k * f0 < f_max:
            x += (1 / k) * np.sin(2 * np.pi * k * f0 * t)
    
    # Normalisation
    x = x / np.max(np.abs(x)) * A
    return x, t


def note_name(f0):
    """
    Retourne le nom de la note la plus proche d'une fréquence donnée.
    
    f0 : fréquence en Hz
    
    Retourne : (nom_note, octave, erreur_cents)
    """
    notes = ['Do', 'Do#', 'Ré', 'Ré#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si']
    
    # Nombre de demi-tons par rapport à La4 (440 Hz)
    n = 12 * np.log2(f0 / 440)
    n_arrondi = int(np.round(n))
    
    # Erreur en cents
    erreur_cents = (n - n_arrondi) * 100
    
    # Nom de la note
    idx = (n_arrondi + 9) % 12  # La = index 9 dans la liste
    octave = 4 + (n_arrondi + 9) // 12
    
    return notes[idx], octave, erreur_cents

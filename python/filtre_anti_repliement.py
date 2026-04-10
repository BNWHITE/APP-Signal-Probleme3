"""
==========================================================================
 FILTRE_ANTI_REPLIEMENT.py - Conception du filtre anti-repliement
 APP Signal - ISEP 2025-2026 - Problème III
==========================================================================
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import os


def concevoir_filtre(Fe=44100, f_pass=20000, f_stop=22050, Apass_dB=0.1, Astop_dB=90):
    """
    Conçoit un filtre anti-repliement passe-bas.
    
    Paramètres :
        Fe       : fréquence d'échantillonnage (Hz)
        f_pass   : fréquence de fin de bande passante (Hz)
        f_stop   : fréquence de début de bande atténuée (Hz)
        Apass_dB : ondulation max en bande passante (dB)
        Astop_dB : atténuation min en bande atténuée (dB)
    """
    print(f"\n--- Gabarit du filtre anti-repliement ---")
    print(f"  Type             : Passe-bas")
    print(f"  Fe               : {Fe} Hz")
    print(f"  Fpass (fc)       : {f_pass} Hz")
    print(f"  Fstop (fa)       : {f_stop} Hz")
    print(f"  Bande transition : Δf = {f_stop - f_pass} Hz")
    print(f"  Apass            : {Apass_dB} dB")
    print(f"  Astop            : {Astop_dB} dB")
    
    # Conversion en delta
    delta1 = 10**(Apass_dB / 20) - 1
    delta2 = 10**(-Astop_dB / 20)
    print(f"  δ1               : {delta1:.6f}")
    print(f"  δ2               : {delta2:.6e}")
    
    # Fréquences normalisées (entre 0 et 1, Nyquist = 1)
    Wpass = f_pass / (Fe / 2)
    Wstop = f_stop / (Fe / 2)
    
    print(f"\n  Fréquences normalisées : Wpass = {Wpass:.4f}, Wstop = {Wstop:.4f}")
    
    # Estimation de l'ordre (formule de Kaiser)
    delta_f = f_stop - f_pass
    N_kaiser = int(np.ceil((-20 * np.log10(np.sqrt(delta1 * delta2)) - 13) / (14.6 * delta_f / Fe)))
    print(f"\n  Estimation de l'ordre (Kaiser) : N ≈ {N_kaiser}")
    
    # Conception du filtre avec remez (equiripple / Parks-McClellan)
    try:
        # Méthode remez
        bands = [0, f_pass, f_stop, Fe/2]
        desired = [1, 0]
        weights = [1/delta1, 1/delta2]
        
        N_remez = N_kaiser
        h = signal.remez(N_remez + 1, bands, desired, weight=weights, fs=Fe)
        methode = "Parks-McClellan (remez)"
    except Exception:
        # Fallback : fenêtre de Kaiser
        beta = signal.kaiser_beta(Astop_dB)
        N_remez = signal.kaiser_ord(delta2, (f_stop - f_pass) / (Fe / 2))[0]
        h = signal.firwin(N_remez + 1, f_pass, window=('kaiser', beta), fs=Fe)
        methode = "Fenêtre de Kaiser"
    
    print(f"  Méthode          : {methode}")
    print(f"  Ordre du filtre  : {len(h) - 1}")
    print(f"  Nb coefficients  : {len(h)}")
    
    # Réponse en fréquence
    w, H = signal.freqz(h, worN=8192, fs=Fe)
    H_dB = 20 * np.log10(np.abs(H) + 1e-15)
    
    # Vérification des performances
    print(f"\n--- Performances du filtre ---")
    
    # Ondulation en bande passante
    idx_bp = w <= f_pass
    if np.any(idx_bp):
        ondulation = np.max(np.abs(H_dB[idx_bp]))
        print(f"  Ondulation BP    : {ondulation:.4f} dB (cible ≤ {Apass_dB} dB)")
    
    # Atténuation en bande atténuée
    idx_ba = w >= f_stop
    if np.any(idx_ba):
        attenuation = -np.max(H_dB[idx_ba])
        print(f"  Atténuation BA   : {attenuation:.1f} dB (cible ≥ {Astop_dB} dB)")
    
    # Fréquence de coupure à -3 dB
    idx_3dB = np.where(H_dB <= -3)[0]
    if len(idx_3dB) > 0:
        f_3dB = w[idx_3dB[0]]
        print(f"  Fréquence -3 dB  : {f_3dB:.0f} Hz")
    
    # Complexité
    print(f"\n  Complexité par échantillon : {len(h)} multiplications + {len(h)-1} additions")
    print(f"  Opérations/seconde : {len(h) * Fe:.0f} MAC/s")
    
    # --- AFFICHAGE ---
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f"Filtre anti-repliement passe-bas - Ordre {len(h)-1}", fontsize=14, fontweight='bold')
    
    # Réponse en fréquence (dB)
    ax1 = axes[0, 0]
    ax1.plot(w / 1000, H_dB, 'b', linewidth=1.5)
    ax1.axvline(f_pass / 1000, color='r', linestyle='--', label=f'fc = {f_pass/1000:.0f} kHz')
    ax1.axvline(f_stop / 1000, color='g', linestyle='--', label=f'Fe/2 = {f_stop/1000:.2f} kHz')
    ax1.axhline(-Astop_dB, color='k', linestyle='--', alpha=0.5, label=f'-{Astop_dB} dB')
    ax1.set_xlabel('Fréquence (kHz)')
    ax1.set_ylabel('|H(f)| (dB)')
    ax1.set_title('Réponse en fréquence (dB)')
    ax1.set_xlim([0, Fe / 2 / 1000])
    ax1.set_ylim([-120, 5])
    ax1.legend()
    ax1.grid(True)
    
    # Réponse en fréquence (linéaire)
    ax2 = axes[0, 1]
    ax2.plot(w / 1000, np.abs(H), 'b', linewidth=1.5)
    ax2.axvline(f_pass / 1000, color='r', linestyle='--', label='fc')
    ax2.axvline(f_stop / 1000, color='g', linestyle='--', label='Fe/2')
    ax2.set_xlabel('Fréquence (kHz)')
    ax2.set_ylabel('|H(f)|')
    ax2.set_title('Réponse en fréquence (linéaire)')
    ax2.set_xlim([0, Fe / 2 / 1000])
    ax2.legend()
    ax2.grid(True)
    
    # Zoom bande passante
    ax3 = axes[1, 0]
    ax3.plot(w / 1000, H_dB, 'b', linewidth=1.5)
    ax3.axhline(-Apass_dB, color='r', linestyle='--', alpha=0.5)
    ax3.axhline(Apass_dB, color='r', linestyle='--', alpha=0.5)
    ax3.set_xlabel('Fréquence (kHz)')
    ax3.set_ylabel('|H(f)| (dB)')
    ax3.set_title('Zoom bande passante')
    ax3.set_xlim([0, f_pass * 1.1 / 1000])
    ax3.set_ylim([-1, 1])
    ax3.grid(True)
    
    # Réponse impulsionnelle
    ax4 = axes[1, 1]
    ax4.stem(np.arange(len(h)), h, linefmt='b-', markerfmt='bo', basefmt='k-', use_line_collection=True)
    ax4.set_xlabel('n')
    ax4.set_ylabel('h(n)')
    ax4.set_title(f'Réponse impulsionnelle (N = {len(h)})')
    ax4.grid(True)
    
    plt.tight_layout()
    
    # Sauvegarde
    os.makedirs('../figures', exist_ok=True)
    plt.savefig('../figures/filtre_anti_repliement.png', dpi=150, bbox_inches='tight')
    print(f"\n  Figure sauvegardée : ../figures/filtre_anti_repliement.png")
    
    return h, w, H


if __name__ == "__main__":
    h, w, H = concevoir_filtre()
    plt.show()

"""
==========================================================================
 SIMULATION_QUANTIFICATION.py - Simulation de la quantification
 APP Signal - ISEP 2025-2026 - Problème III
==========================================================================
"""

import numpy as np
import matplotlib.pyplot as plt
import os


def quantifier(x, b, A=1.0):
    """
    Quantifie un signal sur b bits.
    
    x : signal d'entrée (amplitude entre -A/2 et +A/2)
    b : nombre de bits
    A : dynamique totale
    
    Retourne : signal quantifié, erreur de quantification
    """
    x_q = np.round(x * 2**(b - 1)) / 2**(b - 1)
    e = x - x_q
    return x_q, e


def calcul_snr(x, x_q):
    """Calcule le SNR en dB."""
    e = x - x_q
    P_signal = np.mean(x**2)
    P_erreur = np.mean(e**2)
    if P_erreur > 0:
        return 10 * np.log10(P_signal / P_erreur)
    return np.inf


def simulation_quantification(Fe=44100, V_max=0.5, b_max=20, f0=1000):
    """
    Simule la quantification pour différents nombres de bits.
    
    Fe    : fréquence d'échantillonnage (Hz)
    V_max : amplitude crête (V)
    b_max : nombre max de bits à tester
    f0    : fréquence du signal test (Hz)
    """
    A = 2 * V_max
    duree = 0.1  # secondes
    t = np.arange(0, duree, 1/Fe)
    N = len(t)
    
    # Signal test : sinusoïde
    x = V_max * np.sin(2 * np.pi * f0 * t)
    
    print(f"  Signal test : sinusoïde {f0:.0f} Hz, amplitude {V_max} V")
    print(f"  Fe = {Fe} Hz, durée = {duree} s, N = {N} échantillons")
    
    bits_range = np.arange(1, b_max + 1)
    SNR_mesure = np.zeros(len(bits_range))
    SNR_theorie = np.zeros(len(bits_range))
    debits = np.zeros(len(bits_range))
    
    for idx, b in enumerate(bits_range):
        x_q, e = quantifier(x, b, A)
        
        P_signal = np.mean(x**2)
        P_erreur = np.mean(e**2)
        
        if P_erreur > 0:
            SNR_mesure[idx] = 10 * np.log10(P_signal / P_erreur)
        else:
            SNR_mesure[idx] = 200  # valeur maximale pour l'affichage
        
        q = A / (2**b)
        Pe_th = q**2 / 12
        SNR_theorie[idx] = 10 * np.log10(P_signal / Pe_th)
        
        debits[idx] = Fe * b * 2  # stéréo
    
    # Nombre de bits minimum pour 90 dB
    idx_90 = np.where(SNR_mesure >= 90)[0]
    if len(idx_90) > 0:
        b_min_90 = bits_range[idx_90[0]]
        print(f"\n  Nombre de bits minimum pour SNR ≥ 90 dB : {b_min_90} bits")
        print(f"  Débit stéréo correspondant : {debits[idx_90[0]]/1000:.2f} kbits/s")
    
    # --- AFFICHAGE ---
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle('Simulation de la quantification - Problème III', fontsize=14, fontweight='bold')
    
    # SNR vs bits
    ax1 = axes[0, 0]
    ax1.plot(bits_range, SNR_mesure, 'bo-', linewidth=1.5, markersize=4, label='Mesuré')
    ax1.plot(bits_range, SNR_theorie, 'r--', linewidth=1.5, label='Théorique')
    ax1.axhline(90, color='g', linestyle='--', linewidth=1.5, label='Cible 90 dB')
    ax1.set_xlabel('Nombre de bits (b)')
    ax1.set_ylabel('SNR (dB)')
    ax1.set_title('SNR vs nombre de bits')
    ax1.legend()
    ax1.grid(True)
    
    # SNR vs débit
    ax2 = axes[0, 1]
    ax2.plot(debits / 1000, SNR_mesure, 'bo-', linewidth=1.5, markersize=4)
    ax2.axhline(90, color='g', linestyle='--', linewidth=1.5, label='Cible 90 dB')
    ax2.set_xlabel('Débit (kbits/s)')
    ax2.set_ylabel('SNR (dB)')
    ax2.set_title('SNR vs débit (stéréo)')
    ax2.legend()
    ax2.grid(True)
    
    # Erreur théorique vs mesurée
    ax3 = axes[0, 2]
    ax3.plot(bits_range, SNR_mesure - SNR_theorie, 'ko-', linewidth=1, markersize=3)
    ax3.set_xlabel('Nombre de bits (b)')
    ax3.set_ylabel('Écart SNR (dB)')
    ax3.set_title('Écart mesure - théorie')
    ax3.grid(True)
    
    # Signaux quantifiés pour différents bits
    b_examples = [4, 8, 12, 16]
    n_plot = min(200, N)
    t_plot = t[:n_plot] * 1000  # en ms
    
    for i, b_ex in enumerate(b_examples):
        ax = axes[1, i] if i < 3 else None
        if ax is None:
            break
        
        x_q_ex, e_ex = quantifier(x[:n_plot], b_ex, A)
        snr_ex = calcul_snr(x[:n_plot], x_q_ex)
        
        ax.plot(t_plot, x[:n_plot], 'b-', linewidth=0.5, alpha=0.7, label='Original')
        ax.plot(t_plot, x_q_ex, 'r-', linewidth=1, label='Quantifié')
        ax.set_xlabel('Temps (ms)')
        ax.set_ylabel('Amplitude (V)')
        ax.set_title(f'b = {b_ex} bits, SNR = {snr_ex:.1f} dB')
        ax.legend(fontsize=7)
        ax.grid(True)
    
    plt.tight_layout()
    
    # Sauvegarde
    os.makedirs('../figures', exist_ok=True)
    plt.savefig('../figures/simulation_quantification.png', dpi=150, bbox_inches='tight')
    print(f"\n  Figure sauvegardée : ../figures/simulation_quantification.png")
    
    # Tableau des résultats
    print(f"\n  {'b':>4} | {'SNR mesuré':>12} | {'SNR théorique':>14} | {'Débit stéréo':>16}")
    print(f"  {'':->4}-+-{'':->12}-+-{'':->14}-+-{'':->16}")
    for idx, b in enumerate(bits_range):
        print(f"  {b:4d} | {SNR_mesure[idx]:10.2f} dB | {SNR_theorie[idx]:12.2f} dB | {debits[idx]/1000:12.2f} kb/s")
    
    return bits_range, SNR_mesure, SNR_theorie


if __name__ == "__main__":
    simulation_quantification()
    plt.show()

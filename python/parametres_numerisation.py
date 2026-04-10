"""
==========================================================================
 PARAMETRES_NUMERISATION.py - Calcul de tous les paramètres
 APP Signal - ISEP 2025-2026 - Problème III
==========================================================================
"""

import numpy as np


class ParametresNumerisation:
    """Classe regroupant tous les calculs de paramètres pour la numérisation Hi-Fi."""
    
    def __init__(self, f_min=20, f_max=20000, SNR_cible=90, V_max=0.5, P_moy=30e-3, n_canaux=2):
        self.f_min = f_min          # Hz
        self.f_max = f_max          # Hz
        self.SNR_cible = SNR_cible  # dB
        self.V_max = V_max          # V (amplitude crête)
        self.A = 2 * V_max          # Dynamique totale (V)
        self.P_moy = P_moy          # Puissance moyenne (W)
        self.n_canaux = n_canaux    # Nombre de canaux
        
        # Paramètres calculés
        self.Fe = None
        self.b = None
        self.q = None
        self.SNR_obtenu = None
        self.debit = None
        self.stockage_Mo = None
    
    def afficher_donnees(self):
        """Affiche les données du problème."""
        print(f"  Bande de fréquences : [{self.f_min} Hz, {self.f_max} Hz]")
        print(f"  SNR cible : {self.SNR_cible} dB")
        print(f"  Dynamique du micro : [-{self.V_max*1000:.0f} mV, +{self.V_max*1000:.0f} mV]")
        print(f"  Puissance moyenne : {self.P_moy*1000:.0f} mW")
        print(f"  Puissance en dBm : {10*np.log10(self.P_moy/1e-3):.2f} dBm")
        print(f"  Nombre de canaux : {self.n_canaux} ({'stéréo' if self.n_canaux == 2 else 'mono'})")
    
    def calculer_frequence_echantillonnage(self):
        """Calcule la fréquence d'échantillonnage selon Shannon."""
        Fe_min = 2 * self.f_max
        print(f"  Théorème de Shannon : Fe >= 2 × f_max = 2 × {self.f_max} = {Fe_min} Hz")
        
        # Choix standard CD
        self.Fe = 44100
        marge = self.Fe / 2 - self.f_max
        print(f"  Choix : Fe = {self.Fe} Hz (standard CD)")
        print(f"  Fe/2 = {self.Fe//2} Hz > f_max = {self.f_max} Hz → Shannon respecté ✓")
        print(f"  Marge pour filtre anti-repliement : {marge:.0f} Hz")
        
        return self.Fe
    
    def calculer_nombre_bits(self):
        """Calcule le nombre de bits de quantification."""
        # Méthode 1 : approximation sinus pleine échelle
        b_approx = int(np.ceil((self.SNR_cible - 1.76) / 6.02))
        SNR_approx = 6.02 * b_approx + 1.76
        print(f"  Méthode 1 (sinus pleine échelle) :")
        print(f"    SNR = 6.02×b + 1.76")
        print(f"    b >= ({self.SNR_cible} - 1.76) / 6.02 = {(self.SNR_cible - 1.76)/6.02:.2f} → b = {b_approx} bits")
        print(f"    SNR obtenu = {SNR_approx:.2f} dB")
        
        # Méthode 2 : calcul exact avec P_moy
        C = 10 * np.log10(12 * self.P_moy / self.A**2)
        b_exact = (self.SNR_cible - C) / (20 * np.log10(2))
        b_calcul = int(np.ceil(b_exact))
        
        print(f"\n  Méthode 2 (avec P_moy = {self.P_moy*1000:.0f} mW) :")
        print(f"    SNR = 10×log10(12×P_moy/A²) + 6.02×b")
        print(f"    SNR = {C:.2f} + 6.02×b")
        print(f"    b >= ({self.SNR_cible} - ({C:.2f})) / 6.02 = {b_exact:.2f} → b = {b_calcul} bits")
        
        # Vérification
        self.b = max(b_calcul, 16)  # Au minimum 16 bits
        self.q = self.A / (2**self.b)
        Pe = self.q**2 / 12
        self.SNR_obtenu = 10 * np.log10(self.P_moy / Pe)
        
        print(f"\n  ★ Choix : b = {self.b} bits")
        print(f"    q = {self.q:.6e} V")
        print(f"    SNR obtenu = {self.SNR_obtenu:.2f} dB (cible : {self.SNR_cible} dB) ✓")
        
        return self.b
    
    def calculer_debit_stockage(self):
        """Calcule le débit binaire et le stockage."""
        if self.Fe is None or self.b is None:
            self.calculer_frequence_echantillonnage()
            self.calculer_nombre_bits()
        
        debit_mono = self.Fe * self.b
        self.debit = debit_mono * self.n_canaux
        
        print(f"  Débit mono   = {self.Fe} × {self.b} = {debit_mono} bits/s = {debit_mono/1000:.2f} kbits/s")
        print(f"  Débit stéréo = {self.debit} bits/s = {self.debit/1000:.2f} kbits/s = {self.debit/1e6:.4f} Mbits/s")
        
        # Stockage pour 1h
        duree = 3600  # 1 heure
        vol_bits = self.debit * duree
        vol_octets = vol_bits / 8
        self.stockage_Mo = vol_octets / (1024**2)
        stockage_Go = self.stockage_Mo / 1024
        
        print(f"\n  Stockage pour 1h de concert stéréo :")
        print(f"    Volume = {vol_bits:.2e} bits = {vol_octets:.2e} octets")
        print(f"    Volume = {self.stockage_Mo:.2f} Mo = {stockage_Go:.4f} Go")
        
        return self.debit, self.stockage_Mo
    
    def verifier_compatibilite_cd(self):
        """Vérifie la compatibilité avec le standard CD."""
        if self.stockage_Mo is None:
            self.calculer_debit_stockage()
        
        capacite_cd = 700  # Mo
        
        print(f"  Standard CD : Fe = 44100 Hz, 16 bits, stéréo")
        print(f"  Capacité CD : {capacite_cd} Mo")
        print(f"  Nos paramètres : Fe = {self.Fe} Hz, {self.b} bits, {self.n_canaux} canaux")
        print(f"  Stockage 1h = {self.stockage_Mo:.2f} Mo")
        
        if self.stockage_Mo <= capacite_cd:
            duree_max = capacite_cd / self.stockage_Mo * 60  # en minutes
            print(f"  → Compatible CD ({self.stockage_Mo:.2f} Mo ≤ {capacite_cd} Mo) ✓")
            print(f"  → Durée max sur CD : {duree_max:.1f} min")
        else:
            print(f"  → NON compatible CD ({self.stockage_Mo:.2f} Mo > {capacite_cd} Mo) ✗")
        
        if self.Fe == 44100 and self.b == 16:
            print(f"  → Paramètres IDENTIQUES au standard CD ✓")
    
    def analyser_timbre(self):
        """Analyse la compatibilité avec le timbre des instruments."""
        if self.Fe is None:
            self.calculer_frequence_echantillonnage()
        
        f_nyquist = self.Fe / 2
        
        instruments = [
            ("Piccolo",      630,  5000, 12000),
            ("Flûte",        260,  2400,  8000),
            ("Violon",       200,  3200, 15000),
            ("Piano",         28,  4200, 15000),
            ("Contrebasse",   40,   300,  6000),
            ("Cymbales",     300, 10000, 16000),
            ("Trompette",    190,  1200, 12000),
        ]
        
        print(f"  Fe/2 = {f_nyquist:.0f} Hz (fréquence de Nyquist)")
        print(f"\n  {'Instrument':<14} | {'f0 min':>8} | {'f0 max':>8} | {'Harm. max':>10} | Capturé ?")
        print(f"  {'-'*14}-+-{'-'*8}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}")
        
        tous_captures = True
        for nom, f0_min, f0_max, f_harm in instruments:
            capture = f_harm <= f_nyquist
            tous_captures = tous_captures and capture
            print(f"  {nom:<14} | {f0_min:>6} Hz | {f0_max:>6} Hz | {f_harm:>8} Hz | {'✓' if capture else '✗'}")
        
        if tous_captures:
            print(f"\n  → Le timbre de TOUS les instruments est respecté ✓")
        else:
            print(f"\n  → Certaines harmoniques sont perdues ✗")
    
    def afficher_recapitulatif(self):
        """Affiche le tableau récapitulatif final."""
        if self.Fe is None or self.b is None or self.debit is None:
            self.calculer_frequence_echantillonnage()
            self.calculer_nombre_bits()
            self.calculer_debit_stockage()
        
        print("\n" + "=" * 55)
        print("  RÉCAPITULATIF")
        print("=" * 55)
        print(f"  {'Paramètre':<32} | {'Valeur'}")
        print(f"  {'-'*32}-+-{'-'*20}")
        print(f"  {'Bande audio':<32} | [{self.f_min} Hz, {self.f_max} Hz]")
        print(f"  {'Fréq. échantillonnage (Fe)':<32} | {self.Fe} Hz")
        print(f"  {'Nombre de bits (b)':<32} | {self.b} bits")
        print(f"  {'Pas de quantification (q)':<32} | {self.q*1e6:.3f} µV")
        print(f"  {'Niveaux de quantification':<32} | {2**self.b}")
        print(f"  {'SNR de quantification':<32} | {self.SNR_obtenu:.2f} dB")
        print(f"  {'Nombre de canaux':<32} | {self.n_canaux} (stéréo)")
        print(f"  {'Débit binaire':<32} | {self.debit/1000:.0f} kbits/s")
        print(f"  {'Stockage 1h stéréo':<32} | {self.stockage_Mo:.2f} Mo")
        print(f"  {'Compatible CD':<32} | {'Oui' if self.stockage_Mo <= 700 else 'Non'}")
        print("=" * 55)


if __name__ == "__main__":
    params = ParametresNumerisation()
    params.afficher_donnees()
    params.calculer_frequence_echantillonnage()
    params.calculer_nombre_bits()
    params.calculer_debit_stockage()
    params.verifier_compatibilite_cd()
    params.analyser_timbre()
    params.afficher_recapitulatif()

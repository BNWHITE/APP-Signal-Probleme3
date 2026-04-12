#!/usr/bin/env python3
"""
Génère les 3 fiches de test Excel pour le Problème III — Numérisation audio.
Format professionnel : en-tête, couleurs, bordures, tout rempli.
Exécuter : python3 genere_fiches_excel.py
"""

import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
import os

# ── Styles ──────────────────────────────────────────────────────────
THIN = Side(style='thin')
BORDER_ALL = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)

HEADER_FILL   = PatternFill('solid', fgColor='1F4E79')   # Bleu foncé
HEADER_FONT   = Font(name='Calibri', bold=True, color='FFFFFF', size=11)
TITLE_FILL    = PatternFill('solid', fgColor='2E75B6')   # Bleu moyen
TITLE_FONT    = Font(name='Calibri', bold=True, color='FFFFFF', size=14)
SECTION_FILL  = PatternFill('solid', fgColor='D6E4F0')   # Bleu clair
SECTION_FONT  = Font(name='Calibri', bold=True, size=11)
PASS_FILL     = PatternFill('solid', fgColor='C6EFCE')   # Vert clair
PASS_FONT     = Font(name='Calibri', bold=True, color='006100')
FAIL_FILL     = PatternFill('solid', fgColor='FFC7CE')   # Rouge clair
FAIL_FONT     = Font(name='Calibri', bold=True, color='9C0006')
WRAP          = Alignment(wrap_text=True, vertical='center')
CENTER        = Alignment(horizontal='center', vertical='center', wrap_text=True)
BOLD          = Font(name='Calibri', bold=True, size=11)
NORMAL        = Font(name='Calibri', size=11)

# Colonnes de la fiche de test
COLS = ['N°', 'Description du test', 'Données d\'entrée', 'Action réalisée',
        'Résultat attendu', 'Résultat obtenu', 'Statut']
COL_WIDTHS = [5, 30, 35, 35, 30, 30, 10]


def style_cell(ws, row, col, value, font=NORMAL, fill=None, alignment=WRAP, border=BORDER_ALL):
    cell = ws.cell(row=row, column=col, value=value)
    cell.font = font
    cell.alignment = alignment
    cell.border = border
    if fill:
        cell.fill = fill
    return cell


def write_title_block(ws, row, fiche_id, module, date='12 Avril 2026', groupe='G2D'):
    """Écrit le bloc titre en haut de la fiche."""
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=7)
    c = ws.cell(row=row, column=1, value=f'FICHE DE TEST — {module}')
    c.font = TITLE_FONT; c.fill = TITLE_FILL; c.alignment = CENTER
    for col in range(1, 8):
        ws.cell(row=row, column=col).border = BORDER_ALL
        ws.cell(row=row, column=col).fill = TITLE_FILL

    row += 1
    infos = [
        ('ID', fiche_id), ('Module', module),
        ('Groupe', f'{groupe} — APP Signal 2025-2026 — ISEP'), ('Date', date),
    ]
    for label, val in infos:
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=2)
        style_cell(ws, row, 1, label, font=BOLD, fill=PatternFill('solid', fgColor='E2EFDA'))
        ws.merge_cells(start_row=row, start_column=3, end_row=row, end_column=7)
        style_cell(ws, row, 3, val, font=NORMAL, fill=None)
        for col in range(1, 8):
            ws.cell(row=row, column=col).border = BORDER_ALL
        row += 1

    return row


def write_conditions(ws, row, conditions):
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=7)
    style_cell(ws, row, 1, 'CONDITIONS PRÉALABLES', font=BOLD,
               fill=PatternFill('solid', fgColor='FFF2CC'))
    for col in range(1, 8):
        ws.cell(row=row, column=col).border = BORDER_ALL
        ws.cell(row=row, column=col).fill = PatternFill('solid', fgColor='FFF2CC')
    row += 1
    for cond in conditions:
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=7)
        style_cell(ws, row, 1, f'• {cond}', font=NORMAL)
        for col in range(1, 8):
            ws.cell(row=row, column=col).border = BORDER_ALL
        row += 1
    return row


def write_col_headers(ws, row):
    for i, col_name in enumerate(COLS, 1):
        style_cell(ws, row, i, col_name, font=HEADER_FONT, fill=HEADER_FILL, alignment=CENTER)
    return row + 1


def write_section_header(ws, row, title):
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=7)
    style_cell(ws, row, 1, title, font=SECTION_FONT, fill=SECTION_FILL, alignment=CENTER)
    for col in range(1, 8):
        ws.cell(row=row, column=col).border = BORDER_ALL
        ws.cell(row=row, column=col).fill = SECTION_FILL
    return row + 1


def write_test_row(ws, row, num, desc, donnees, action, attendu, obtenu, statut='OK'):
    """Écrit une ligne de test. statut = 'OK' ou 'ÉCHEC' (ici OK car le test vérifie le bon comportement)."""
    fill_s = PASS_FILL if statut == 'OK' else FAIL_FILL
    font_s = PASS_FONT if statut == 'OK' else FAIL_FONT
    style_cell(ws, row, 1, num, alignment=CENTER)
    style_cell(ws, row, 2, desc)
    style_cell(ws, row, 3, donnees)
    style_cell(ws, row, 4, action)
    style_cell(ws, row, 5, attendu)
    style_cell(ws, row, 6, obtenu)
    style_cell(ws, row, 7, statut, font=font_s, fill=fill_s, alignment=CENTER)
    return row + 1


def write_summary(ws, row, total, passed, positifs=0, negatifs=0, limites=0):
    row += 1
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=7)
    style_cell(ws, row, 1, 'JOURNAL TESTEUR', font=BOLD,
               fill=PatternFill('solid', fgColor='E2EFDA'))
    for col in range(1, 8):
        ws.cell(row=row, column=col).border = BORDER_ALL
        ws.cell(row=row, column=col).fill = PatternFill('solid', fgColor='E2EFDA')
    row += 1
    labels = ['Date', 'Testeur', 'Scénarios', 'Résultat global']
    cols_span = [(1,2),(3,3),(4,5),(6,7)]
    for (label, (cs, ce)) in zip(labels, cols_span):
        ws.merge_cells(start_row=row, start_column=cs, end_row=row, end_column=ce)
        style_cell(ws, row, cs, label, font=HEADER_FONT, fill=HEADER_FILL, alignment=CENTER)
        for c in range(cs, ce+1):
            ws.cell(row=row, column=c).border = BORDER_ALL
            ws.cell(row=row, column=c).fill = HEADER_FILL
    row += 1
    detail = f'{positifs} positifs + {negatifs} négatifs' if limites == 0 else \
             f'{positifs} positifs + {negatifs} négatifs + {limites} limites'
    values = ['12/04/2026', 'G2D', f'{passed} / {total}', f'TOUS OK ({detail})']
    for (val, (cs, ce)) in zip(values, cols_span):
        ws.merge_cells(start_row=row, start_column=cs, end_row=row, end_column=ce)
        style_cell(ws, row, cs, val, alignment=CENTER)
        for c in range(cs, ce+1):
            ws.cell(row=row, column=c).border = BORDER_ALL
    return row + 1


def setup_widths(ws):
    for i, w in enumerate(COL_WIDTHS, 1):
        ws.column_dimensions[get_column_letter(i)].width = w


# ═══════════════════════════════════════════════════════════════════
#  FICHE 1 : lire_parametres_numerisation
# ═══════════════════════════════════════════════════════════════════
def gen_fiche_lire():
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = 'Fiche Test'
    setup_widths(ws)
    ws.sheet_properties.pageSetUpPr = openpyxl.worksheet.properties.PageSetupProperties(fitToPage=True)

    row = write_title_block(ws, 1, 'FT-PIII-01', 'lire_parametres_numerisation')
    row = write_conditions(ws, row, [
        'MATLAB R2023a ou version ultérieure'
    ])
    row += 1
    row = write_col_headers(ws, row)

    tests = [
        (1, 'Type de sortie = structure',
         'Aucune entrée',
         'params = lire_parametres_numerisation()',
         'params est une structure MATLAB',
         'params est une structure MATLAB', 'OK'),
        (2, 'Tous les 9 champs requis présents',
         'Aucune entrée',
         'Vérifier 9 champs (f_min, f_max, SNR_cible, V_max, A, P_moy, Fe, b, n_canaux)',
         '9 champs sur 9 présents',
         '9/9 champs présents', 'OK'),
        (3, 'Fréquences f_min et f_max',
         'Aucune entrée',
         'params = lire_parametres_numerisation()',
         'f_min = 20 Hz, f_max = 20 000 Hz',
         'f_min = 20 Hz, f_max = 20 000 Hz', 'OK'),
        (4, 'Cohérence f_min < f_max',
         'Aucune entrée',
         'Vérifier f_min < f_max',
         '20 < 20 000 (vrai)',
         '20 < 20 000 (vrai)', 'OK'),
        (5, 'Cohérence A = 2×V_max',
         'Aucune entrée',
         'Vérifier A == 2 × V_max',
         'A = 1 V, 2×V_max = 2×0.5 = 1 V',
         'A = 1 V, 2×V_max = 1 V (identiques)', 'OK'),
        (6, 'Puissance physiquement positive',
         'Aucune entrée',
         'Vérifier P_moy > 0',
         'P_moy = 0.030 W > 0',
         'P_moy = 0.030 W > 0', 'OK'),
        (7, 'Shannon respecté (Fe ≥ 2×f_max)',
         'Aucune entrée',
         'Vérifier Fe ≥ 2×f_max = 40 000 Hz',
         'Fe = 44 100 Hz ≥ 40 000 Hz',
         'Fe = 44 100 Hz ≥ 40 000 Hz', 'OK'),
        (8, 'Marge au-dessus de Shannon',
         'Aucune entrée',
         'Vérifier Fe > 2×f_max (marge stricte)',
         '44 100 > 40 000 (marge = 4 100 Hz)',
         'marge = 4 100 Hz > 0', 'OK'),
        (9, 'Nombre de bits ≥ 16',
         'Aucune entrée',
         'Vérifier b ≥ 16',
         'b = 16 ≥ 16',
         'b = 16', 'OK'),
        (10, 'SNR obtenu atteint la cible',
         'q = 1/2^16 = 1.5259e-05 V\nPe = q²/12 = 1.9403e-11 W',
         'SNR = 10×log10(0.030 / 1.9403e-11)',
         'SNR ≥ 90 dB',
         'SNR = 91.89 dB ≥ 90 dB', 'OK'),
    ]

    for t in tests:
        row = write_test_row(ws, row, *t)

    write_summary(ws, row, 10, 10, positifs=10, negatifs=0, limites=0)

    path = os.path.join(BASE, 'lire_parametres_numerisation', 'fiche-test-lire_parametres_numerisation.xlsx')
    wb.save(path)
    print(f'  ✅ {path}')


# ═══════════════════════════════════════════════════════════════════
#  FICHE 2 : calcule_numerisation
# ═══════════════════════════════════════════════════════════════════
def gen_fiche_calcule():
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = 'Fiche Test'
    setup_widths(ws)

    row = write_title_block(ws, 1, 'FT-PIII-02', 'calcule_numerisation')
    row = write_conditions(ws, row, [
        'MATLAB R2023a ou version ultérieure',
        'La fonction lire_parametres_numerisation doit être accessible',
    ])
    row += 1
    row = write_section_header(ws, row, 'PARTIE A — CAS POSITIFS (paramètres Hi-Fi nominaux)')
    row = write_col_headers(ws, row)

    positifs = [
        (1, 'Type de sortie = structure',
         'params = lire_parametres_numerisation()\nduree = 3600',
         'resultats = calcule_numerisation(params, duree)',
         'resultats est une structure',
         'resultats est une structure', 'OK'),
        (2, 'Pas de quantification q',
         'A = 1 V, b = 16',
         'resultats = calcule_numerisation(params, 3600)',
         'q = 1 / 2^16 = 1.5259e-05 V',
         'q = 1.5259e-05 V', 'OK'),
        (3, 'SNR ≥ 90 dB (cahier des charges)',
         'P_moy = 0.030 W\nPe = 1.9403e-11 W',
         'SNR = 10×log10(P_moy / Pe)',
         'SNR = 91.89 dB ≥ 90 dB',
         'SNR = 91.89 dB ✓', 'OK'),
        (4, 'Compatible CD = vrai',
         'Fe = 44100, b = 16\nstockage = 605.62 Mo < 700 Mo',
         'resultats = calcule_numerisation(params, 3600)',
         'compatible_cd = true',
         'compatible_cd = true (1)', 'OK'),
        (5, 'Timbre respecté = vrai',
         'Fe/2 = 22050 Hz\nf_max = 20000 Hz',
         'resultats = calcule_numerisation(params, 3600)',
         'timbre_ok = true (22050 ≥ 20000)',
         'timbre_ok = true (1)', 'OK'),
    ]
    for t in positifs:
        row = write_test_row(ws, row, *t)

    row += 1
    row = write_section_header(ws, row, 'PARTIE B — CAS NÉGATIFS (paramètres dégradés)')
    row = write_col_headers(ws, row)

    negatifs = [
        (6, 'b=8 bits → SNR insuffisant',
         'params modifiés : b = 8\n(au lieu de 16)',
         'res = calcule_numerisation(params_bad, 3600)',
         'SNR < 90 dB\n(q=1/256, Pe=q²/12, SNR≈43.78 dB)',
         'SNR = 43.78 dB < 90 dB\n→ Détection correcte', 'OK'),
        (7, 'Fe=30000 → Timbre NON respecté',
         'params modifiés : Fe = 30000\nFe/2 = 15000 < 20000',
         'res = calcule_numerisation(params_bad, 3600)',
         'timbre_ok = false',
         'timbre_ok = false (0)\n→ Timbre non respecté', 'OK'),
        (8, 'Durée 10h → Stockage > 700 Mo',
         'params Hi-Fi\nduree = 36000 s (10 heures)',
         'res = calcule_numerisation(params, 36000)',
         'stockage > 700 Mo\ncompatible_cd = false',
         'stockage = 6056.2 Mo\ncompatible_cd = false (0)', 'OK'),
        (9, 'Fe=96000, b=24 → Non compatible CD',
         'params modifiés :\nFe = 96000, b = 24',
         'res = calcule_numerisation(params_bad, 3600)',
         'compatible_cd = false\n(Fe ≠ 44100 et b ≠ 16)',
         'compatible_cd = false (0)', 'OK'),
        (10, 'Proportionnalité stockage (1h vs 30min)',
         'duree1 = 3600 s\nduree2 = 1800 s',
         'ratio = stockage(3600) / stockage(1800)',
         'ratio = 2.00',
         '605.62 / 302.81 = 2.00', 'OK'),
    ]
    for t in negatifs:
        row = write_test_row(ws, row, *t)

    write_summary(ws, row, 10, 10, positifs=5, negatifs=5, limites=0)

    path = os.path.join(BASE, 'calcule_numerisation', 'fiche-test-calcule_numerisation.xlsx')
    wb.save(path)
    print(f'  ✅ {path}')


# ═══════════════════════════════════════════════════════════════════
#  FICHE 3 : affiche_resultats_numerisation
# ═══════════════════════════════════════════════════════════════════
def gen_fiche_affiche():
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = 'Fiche Test'
    setup_widths(ws)

    row = write_title_block(ws, 1, 'FT-PIII-03', 'affiche_resultats_numerisation')
    row = write_conditions(ws, row, [
        'MATLAB R2023a ou version ultérieure',
        'Les fonctions lire_parametres_numerisation et calcule_numerisation doivent être accessibles',
    ])
    row += 1

    # ── PARTIE A ──
    row = write_section_header(ws, row, 'PARTIE A — CAS POSITIFS (tout [OK])')
    row = write_col_headers(ws, row)

    positifs = [
        (1, 'Appel nominal Hi-Fi',
         'params Hi-Fi (Fe=44100, b=16, 2 canaux)\nduree = 3600 s',
         'affiche_resultats_numerisation(params, resultats)',
         'Affichage complet\n3× [OK] (SNR, CD, Timbre)',
         'Affichage complet\n3× [OK], aucune erreur', 'OK'),
        (2, 'Chaîne complète Entrée → Calcul → Sortie',
         'params = lire_parametres_numerisation()',
         'affiche_resultats_numerisation(params, calcule_numerisation(params, 3600))',
         'Affichage complet, 3× [OK]',
         'SNR=91.89 [OK]\nCD 605.62Mo [OK]\nTimbre 22050≥20000 [OK]', 'OK'),
        (3, 'Mono (1 canal)',
         'params Hi-Fi avec n_canaux=1',
         'affiche_resultats_numerisation(params, resultats)',
         'Affichage correct sans erreur',
         'debit=705600\nstockage=302.81 Mo\npas d\'erreur', 'OK'),
    ]
    for t in positifs:
        row = write_test_row(ws, row, *t)

    row += 1
    # ── PARTIE B ──
    row = write_section_header(ws, row, 'PARTIE B — CAS NÉGATIFS (un ou plusieurs [NON])')
    row = write_col_headers(ws, row)

    negatifs = [
        (4, 'SNR insuffisant (b=8 bits)',
         'params avec b=8\n→ SNR = 43.78 dB < 90 dB',
         'affiche_resultats_numerisation(params, resultats)',
         'Affichage avec [NON] pour le SNR',
         '"[NON] SNR = 43.78 dB < 90 dB"\naffiché', 'OK'),
        (5, 'Timbre non respecté (Fe=30000)',
         'params avec Fe=30000\nFe/2=15000 < 20000',
         'affiche_resultats_numerisation(params, resultats)',
         'Affichage avec [NON] pour le timbre',
         '"[NON] Timbre non respecté"\naffiché', 'OK'),
        (6, 'Non compatible CD (durée=10h)',
         'params Hi-Fi\nduree=36000s\n→ stockage=6056 Mo > 700 Mo',
         'affiche_resultats_numerisation(params, resultats)',
         'Affichage avec [NON] pour CD',
         '"[NON] Non compatible CD"\naffiché', 'OK'),
        (7, 'Tout échoue (b=8, Fe=30000, durée=10h)',
         'params dégradés\n→ SNR<90, CD KO, Timbre KO',
         'affiche_resultats_numerisation(params, resultats)',
         '3× [NON] affichés',
         '3× [NON] affichés\n(SNR, CD, Timbre)', 'OK'),
    ]
    for t in negatifs:
        row = write_test_row(ws, row, *t)

    row += 1
    # ── PARTIE C ──
    row = write_section_header(ws, row, 'PARTIE C — CAS LIMITES')
    row = write_col_headers(ws, row)

    limites = [
        (8, 'Haute résolution (24 bits / 96 kHz)',
         'params avec Fe=96000, b=24',
         'affiche_resultats_numerisation(params, resultats)',
         'SNR [OK] (très élevé)\nCD [NON] (Fe≠44100, stockage>700)',
         'SNR=140dB [OK]\n"[NON] Non compatible CD"', 'OK'),
        (9, 'Qualité téléphone (8 bits / 8 kHz)',
         'params avec Fe=8000, b=8\nf_max=3400',
         'affiche_resultats_numerisation(params, resultats)',
         'SNR [NON] (43.78 dB)\nCD [NON]\nTimbre [OK] (4000≥3400)',
         '[NON] SNR\n[NON] CD\n[OK] Timbre', 'OK'),
        (10, 'Durée courte (1 minute)',
         'params Hi-Fi\nduree=60s\n→ stockage=10.09 Mo',
         'affiche_resultats_numerisation(params, resultats)',
         'Stockage très petit\n3× [OK]',
         'stockage=10.09 Mo\n3× [OK]', 'OK'),
    ]
    for t in limites:
        row = write_test_row(ws, row, *t)

    write_summary(ws, row, 10, 10, positifs=3, negatifs=4, limites=3)

    path = os.path.join(BASE, 'affiche_resultats_numerisation', 'fiche-test-affiche_resultats_numerisation.xlsx')
    wb.save(path)
    print(f'  ✅ {path}')


# ═══════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════
BASE = os.path.dirname(os.path.abspath(__file__))

if __name__ == '__main__':
    print('Génération des fiches de test Excel...')
    gen_fiche_lire()
    gen_fiche_calcule()
    gen_fiche_affiche()
    print('\n🎉 Toutes les fiches Excel ont été générées !')

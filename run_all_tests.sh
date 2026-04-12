#!/bin/bash
# ============================================================
#  run_all_tests.sh — Lance tous les tests unitaires du projet
#  APP Signal — Problème III — Groupe G2D — ISEP 2025-2026
# ============================================================
#  Usage :  ./run_all_tests.sh          (utilise Octave par défaut)
#           ./run_all_tests.sh matlab   (utilise MATLAB)
# ============================================================

set -e

# --- Couleurs terminal ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # Reset

# --- Se placer dans le dossier du script (racine du projet) ---
cd "$(dirname "$0")"

# --- Choix du moteur : octave (défaut) ou matlab ---
ENGINE="${1:-octave}"

if [ "$ENGINE" = "matlab" ]; then
    CMD="matlab -batch"
    echo -e "${CYAN}${BOLD}🔧 Moteur : MATLAB${NC}"
    if ! command -v matlab &> /dev/null; then
        echo -e "${RED}❌ MATLAB introuvable dans le PATH. Installez-le ou utilisez Octave :${NC}"
        echo "   ./run_all_tests.sh"
        exit 1
    fi
else
    CMD="octave --no-gui --eval"
    echo -e "${CYAN}${BOLD}🔧 Moteur : GNU Octave${NC}"
    if ! command -v octave &> /dev/null; then
        echo -e "${RED}❌ Octave introuvable. Installez-le :${NC}"
        echo "   brew install octave"
        exit 1
    fi
fi

echo ""

# --- Liste des tests ---
TESTS=(
    "lire_parametres_numerisation/test_lire_parametres_numerisation.m"
    "calcule_numerisation/test_calcule_numerisation.m"
    "affiche_resultats_numerisation/test_affiche_resultats_numerisation.m"
)

TOTAL=${#TESTS[@]}
PASSED=0
FAILED=0
FAILED_NAMES=()

for TEST in "${TESTS[@]}"; do
    MODULE=$(basename "$(dirname "$TEST")")
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}▶ Test : ${MODULE}${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Capture la sortie et le code retour
    OUTPUT=""
    if [ "$ENGINE" = "matlab" ]; then
        OUTPUT=$(matlab -batch "run('$TEST')" 2>&1) && RC=0 || RC=1
    else
        OUTPUT=$(octave --no-gui --eval "run('$TEST')" 2>&1) && RC=0 || RC=1
    fi

    echo "$OUTPUT"
    echo ""

    # Vérifier s'il y a des ECHEC dans la sortie
    if echo "$OUTPUT" | grep -qi "ECHEC" || [ $RC -ne 0 ]; then
        NB_ECHEC=$(echo "$OUTPUT" | grep -ci "ECHEC" || true)
        echo -e "${RED}❌ ${MODULE} — ${NB_ECHEC} cas en ECHEC${NC}"
        FAILED=$((FAILED + 1))
        FAILED_NAMES+=("$MODULE")
    else
        echo -e "${GREEN}✅ ${MODULE} — Tous les cas OK${NC}"
        PASSED=$((PASSED + 1))
    fi
    echo ""
done

# --- Résumé final ---
echo -e "${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}📊 RÉSUMÉ${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "   Modules testés  : ${TOTAL}"
echo -e "   ${GREEN}✅ Réussis       : ${PASSED}${NC}"
echo -e "   ${RED}❌ Échoués       : ${FAILED}${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}   Modules en échec :${NC}"
    for NAME in "${FAILED_NAMES[@]}"; do
        echo -e "${RED}     • ${NAME}${NC}"
    done
    echo ""
    echo -e "${RED}${BOLD}💥 Des tests ont échoué. Corrigez les fonctions avant de rendre !${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}${BOLD}🎉 Tout est OK — prêt à rendre !${NC}"
    exit 0
fi

# Reporting hebdomadaire (indicateurs de service)

## KPI (exemples)
- Disponibilité cluster (SLO)
- Nombre d’incidents (par sévérité) + MTTR
- Lag max sur groupes critiques
- Volume messages/jour + bytes-in/out
- Changes réalisés / backlog tickets
- Capacity : CPU/mem/storage, tendance 4 semaines
- Non-conformités : topics hors standard, ACLs trop permissives (audit)

## Modèle de rapport
Voir : `docs/templates/REPORTING-HEBDO.md`

## Script de collecte (exemple)
`scripts/report-weekly.sh` génère un rapport Markdown à partir de commandes kubectl/oc.

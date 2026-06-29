# Write-up — Pentest Éthique : Kill Chain Complète
**Environnement :** Kali Linux (live USB Rufus) → Machine cible TryHackMe
**Date :** Juin 2026
**Auteur :** Argentina Le Bayec

---

## Objectif

Réaliser une chaîne d'attaque complète (kill chain) dans un environnement légal d'entraînement : de la reconnaissance OSINT jusqu'à l'exploitation d'une vulnérabilité critique, en passant par le scanning réseau.

---

## Étape 1 — Reconnaissance OSINT avec theHarvester

**Objectif :** Collecter des informations publiques sur la cible sans interagir directement avec ses systèmes.

**Commande utilisée :**
```bash
theHarvester -d tryhackme.com -b google

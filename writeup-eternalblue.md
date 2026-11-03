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

## Étape 2 — Scanning réseau avec Nmap

**Objectif :** Identifier les ports ouverts et les versions de services sur la machine cible, pour repérer des vulnérabilités potentielles.

**Commande utilisée :**
**Résultat :** Détection des ports ouverts et des versions de services associées (notamment un service SMB potentiellement vulnérable).

**Pourquoi c'est important :** Un service non patché suffit à compromettre une machine entière.

---

## Étape 3 — Exploitation avec Metasploit / EternalBlue (MS17-010)

**Objectif :** Exploiter la vulnérabilité EternalBlue sur la machine cible d'entraînement.

**Commandes utilisées :**
**Résultat :** Accès obtenu à la machine cible.

**Contexte :** EternalBlue (MS17-010) est la faille exploitée par WannaCry en 2017, qui a paralysé des hôpitaux et des administrations à l'échelle mondiale.

---

## Bilan

| Phase | Outil | Résultat |
|---|---|---|
| Reconnaissance | theHarvester | Sous-domaines et serveurs identifiés |
| Scanning | Nmap | Ports ouverts et versions détectés |
| Exploitation | Metasploit/EternalBlue | Accès machine obtenu |

---

## Environnement technique

- **Attaquant :** Kali Linux 2024, live USB (Rufus)
- **Cible :** Machine virtuelle TryHackMe
- **Cadre :** Entraînement éthique légal

---

## Compétences mobilisées

- OSINT et reconnaissance passive
- Scanning réseau et analyse de services
- Exploitation de vulnérabilités connues (CVE)
- Utilisation de Metasploit Framework

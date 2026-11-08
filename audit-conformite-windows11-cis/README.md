# Durcissement et audit de Windows 11 selon le CIS Benchmark

Projet d'apprentissage réalisé en laboratoire, sur une machine virtuelle. Je me forme à l'audit de configuration et au durcissement de Windows, avec pour horizon la cybersécurité industrielle (validation et conformité).

## Objectif

Prendre un Windows 11 « tel qu'installé », le comparer à un référentiel reconnu, corriger les écarts, puis automatiser la vérification avec un script PowerShell qui produit un rapport.

## Environnement

- Windows 11 Professionnel 25H2 (build 26200.6584), en machine virtuelle VirtualBox
- Référentiel : CIS Microsoft Windows 11 Enterprise Benchmark v5.1.1. Le PDF n'est pas inclus dans ce dépôt : il est téléchargeable gratuitement sur cisecurity.org (usage non commercial)
- Outils : PowerShell, éditeur de stratégie de groupe locale (`gpedit.msc`)
- Un snapshot de la VM a été pris avant toute modification

Le guide s'appelle « Enterprise » alors que ma VM est en édition Pro : les recommandations que j'ai vérifiées s'y appliquent, mais je n'ai pas testé les réglages propres à l'édition Enterprise.

## Méthode

1. Lire la recommandation dans le CIS (niveau, valeur attendue, valeur par défaut)
2. Mesurer l'état réel de la machine (PowerShell, `net accounts`, `gpedit.msc`)
3. Corriger l'écart (`gpedit.msc` ou `Set-ItemProperty`)
4. Relire la valeur pour vérifier la correction
5. Automatiser ces contrôles dans un script

## Écarts corrigés

| Recommandation CIS | Réglage | Avant | Après |
|---|---|---|---|
| 1.1.1 | Historique des mots de passe | Aucun | 24 |
| 1.1.3 | Durée de vie minimale (jours) | 0 | 1 |
| 1.1.4 | Longueur minimale du mot de passe | 0 | 14 |
| 1.2.1 | Durée de verrouillage du compte (min) | 10 | 15 |
| 1.2.2 | Seuil de verrouillage | 10 | 5 |
| 1.2.4 | Réinitialisation du compteur (min) | 10 | 15 |
| 2.3.10.3 | Énumération anonyme des comptes et partages SAM | 0 | 1 |

Déjà conformes au départ : 1.1.2, 2.3.1.1 (compte Invité désactivé), 2.3.10.2, pare-feu actif sur les trois profils (9.1.1, 9.2.1, 9.3.1) et SMBv1 désactivé. Pour 1.1.5 (complexité) et 1.1.7 (chiffrement réversible), l'état de départ n'a pas été relevé : ils sont conformes à la fin.

## Le script

`Audit-Win11-CIS.ps1` vérifie 16 contrôles en lecture seule (il ne modifie rien) et écrit `rapport_audit_CIS.csv`.

À lancer dans PowerShell en administrateur :

```powershell
.\Audit-Win11-CIS.ps1
```

Si l'exécution des scripts est bloquée, autoriser uniquement la fenêtre en cours :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Résultat final sur ma VM : 16 contrôles conformes sur 16.

### Vérifier que le script détecte bien un problème

Un script qui répond toujours « conforme » ne prouve rien. J'ai donc remis volontairement la longueur minimale du mot de passe à 8 : le script a signalé un écart sur 1.1.4 (valeur obtenue 8, résultat 15 conformes sur 16). Après être revenu à 14, il est repassé à 16 sur 16.

## Limites

- Seulement 16 contrôles sur les quelque 530 recommandations du guide
- Le contrôle SMBv1 lit l'état de la fonctionnalité Windows, il a donc un lien indirect avec les règles 18.4.2 et 18.4.3 du CIS
- Un seul poste de test, en édition Pro
- Les niveaux (Level 1 ou 2) n'ont pas tous été relevés un par un
- Pas encore de scan de vulnérabilités

## Suite prévue

- Scanner la VM avec Nessus Essentials depuis Kali, avec puis sans identifiants
- Ajouter d'autres contrôles au script
- Appliquer les mêmes réglages par une vraie GPO sur un domaine Active Directory de laboratoire

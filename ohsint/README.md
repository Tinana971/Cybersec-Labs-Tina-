# Write-up : OhSINT (TryHackMe)

**Niveau :** facile | **Thème :** OSINT (renseignement en sources ouvertes)

## Objectif
À partir d'une seule image, retrouver des informations publiques sur une personne fictive.

## Outils utilisés
- ExifTool (lecture des métadonnées d'une image)
- WiGLE (base de données mondiale de réseaux Wi-Fi)
- Navigateur : code source de la page (Ctrl+U) et sélection du texte (Ctrl+A)

## Démarche

### 1. Métadonnées de l'image
J'ai installé ExifTool sous Windows, puis lu les métadonnées de l'image :

```
.\exiftool.exe ohsint.jpg
```

Deux lignes m'ont mise sur la piste : un pseudo dans le champ Copyright et des coordonnées GPS. Les métadonnées EXIF contenaient des coordonnées GPS, que j'ai converties et vérifiées dans une carte en ligne.

### 2. Piste du pseudo
J'ai recherché le pseudo sur Internet et retrouvé les comptes et le blog de la personne. Chaque information a été notée avec sa source.

### 3. Wi-Fi et géolocalisation
J'ai utilisé WiGLE (recherche par BSSID) pour associer un réseau Wi-Fi à un lieu.

### 4. Contenu caché dans une page web
Un mot de passe était écrit en blanc sur fond blanc dans l'article du blog. Je l'ai trouvé avec Ctrl+A, puis confirmé dans le code source (`color:#ffffff`).

## Difficultés rencontrées
- Fichier renommé par erreur en `exiftool.exe..exe` (l'extension était cachée par Windows) : corrigé avec `Rename-Item`.
- PowerShell ne trouvait pas l'outil : j'étais dans le mauvais dossier (C: au lieu de D:).
- Mot de passe refusé : une lettre et un chiffre se ressemblaient. Le copier-coller a réglé le problème.
- Recherche WiGLE vide au début : zone de la carte mal réglée.

## Ressenti
Room accessible pour une première en OSINT. Le plus long a été la prise en main des outils (ExifTool en ligne de commande, WiGLE), plus que l'enquête elle-même. J'ai aimé voir qu'on peut remonter une piste à partir d'une simple image, et la partie du mot de passe caché m'a appris à regarder ce qu'il y a derrière une page web. Prête pour une room plus poussée.

## Ce que j'ai appris
- Ce qui est invisible à l'écran peut rester lisible dans le code.
- Les métadonnées d'une photo peuvent révéler un lieu et un auteur.
- Les substitutions lettre/chiffre (o remplacé par 0) protègent mal un mot de passe.
- Un enquêteur note toujours la source de chaque indice.

*Les réponses de la room ne sont volontairement pas publiées.*

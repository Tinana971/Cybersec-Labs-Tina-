# Analyse de l'authentification d'un switch D-Link

## Contexte
Exercice réalisé en formation : retrouver le mot de passe admin d'un switch D-Link sans effectuer de reset, en restant en écoute passive/active sur le réseau.

## Méthodologie

### 1. Reconnaissance
Scan Nmap pour identifier les services exposés :

nmap -p 22,23,80,443,161 <IP_switch>

Résultat : port 80 (interface web HTTP non chiffrée) ouvert, port 23 (Telnet) fermé.

### 2. Capture réseau
Capture du trafic HTTP pendant une tentative de connexion légitime :

sudo tcpdump -i eno1 port 80 and host <IP_switch> -A -w capture_http.pcap

Analyse dans Wireshark avec le filtre http.request.method == "POST", puis Follow HTTP Stream.

### 3. Constat
La requête POST /goform/SetLogin est bien visible en clair (HTTP non chiffré), mais le mot de passe est haché côté client en JavaScript avant l'envoi — une protection superficielle qui ne compense pas l'absence de HTTPS.

### 4. Rétro-ingénierie du hachage
Lecture du JavaScript de la page de login (Ctrl+U) :
- Formule identifiée : MD5(motdepasse + "_" + swUserKey), tronqué à 24 caractères.
- swUserKey est codé en dur dans le code source de la page — ce n'est donc pas un sel aléatoire, ce qui annule son intérêt cryptographique.

## Conclusion / faille identifiée
Le hachage côté client donne une fausse impression de sécurité : la valeur de salage étant statique et visible dans le JS, un attaquant peut reconstruire le hash pour n'importe quel mot de passe testé, rendant une attaque par dictionnaire hors ligne possible.

## Pistes d'amélioration côté constructeur
- Chiffrer les échanges (HTTPS/TLS) plutôt que compter sur un hachage JS.
- Utiliser un sel aléatoire généré côté serveur, à usage unique.

## Outils utilisés
Nmap, tcpdump, Wireshark, lecture de code source JavaScript.
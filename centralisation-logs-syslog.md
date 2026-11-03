# Centralisation de logs avec Syslog (Kali / Metasploitable2)

## Contexte
TP réalisé dans le cadre de ma formation TSSR : mise en place d'une centralisation de logs (syslog) entre deux machines virtuelles, pour comprendre comment un attaquant ou un administrateur peut suivre l'activité d'un système à distance — compétence clé en cybersécurité (détection d'intrusion, analyse post-incident).

## Environnement
- Serveur de logs : Kali Linux, 192.168.56.103
- Client (source des logs) : Metasploitable2, 192.168.56.102
- Réseau privé hôte VirtualBox

## Méthodologie

### 1. Installation et configuration du serveur (Kali)
Installation de rsyslog et activation du module de réception UDP, dans la configuration rsyslog :

module(load="imudp")
input(type="imudp" port="514")

Redémarrage du service : sudo systemctl restart rsyslog

### 2. Configuration du client (Metasploitable2)
Dans /etc/syslog.conf, envoi de tous les logs vers le serveur Kali en UDP :

*.* @192.168.56.103:514

(@ signifie UDP, @@ signifie TCP)

### 3. Test de centralisation
Tentative de connexion su root échouée volontairement sur Metasploitable2, puis vérification de sa réception sur Kali.

## Obstacles rencontrés et résolus
- Erreur "unknown priority name" : causée par une tabulation manquante dans le fichier de configuration (syntaxe syslog stricte).
- Logs introuvables dans /var/log/syslog : en réalité bien reçus, mais classés dans /var/log/auth.log sur Kali (logs d'authentification séparés des logs système génériques).
- Lignes dupliquées : causées par une règle de configuration en double.

## Résultat
Centralisation fonctionnelle confirmée : la tentative su root échouée sur Metasploitable2 a bien été retrouvée dans /var/log/auth.log sur Kali, horodatée et attribuée à la bonne machine source.

## Équivalent Windows
Sous Windows, l'équivalent de la consultation/export de logs passe par :
- Observateur d'événements (interface graphique)
- wevtutil et Get-WinEvent (ligne de commande / PowerShell)
- IDs d'événements clés : 4624 (connexion réussie), 4625 (échec de connexion), 1102 (journal effacé), 41 (redémarrage inattendu)

## Outils utilisés
rsyslog, journalctl, VirtualBox (Kali Linux, Metasploitable2).
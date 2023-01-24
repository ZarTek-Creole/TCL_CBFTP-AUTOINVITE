# CBFTP Invite Bot Script (English)
This script allows an Eggdrop bot to automatically invite itself to specific channels on CBFTP sites that it cannot join due to +i (invitation) or +k (key) modes.

**Auto-invite via CBFTP API**

It does this by using the CBFTP API's HTTP interface to send an invite request. The sitebot on the CBFTP site will then automatically invite the bot to the channel, allowing it to join.

This script is particularly useful if you are running your Eggdrop bot behind a ZNC, as it can automatically reconnect to your CBFTP site channels after a disconnection, reboot, or any other event that causes you to lose your presence on the channels.

- [CBFTP Invite Bot Script (English)](#cbftp-invite-bot-script-english)
  - [Prerequisites](#prerequisites)
  - [Configuration](#configuration)
  - [Donation](#donation)
  - [My other codes](#my-other-codes)
  - [Bugs, Improvements](#bugs-improvements)
  - [Contribution](#contribution)
- [CBFTP Invite Bot Script (français)](#cbftp-invite-bot-script-français)
- [Prérequis](#prérequis)
- [Configuration](#configuration-1)
- [Utilisation](#utilisation)
- [Donation](#donation-1)
- [Mes autres codes](#mes-autres-codes)
- [Bogue, Amelioration](#bogue-amelioration)
- [Contribution](#contribution-1)

## Prerequisites
- Eggdrop 1.8 or later
- Tcl 8.5 or later
- cbftp with HTTP API enabled
- The following Tcl packages:
    - http
    - json
    - tls
    - base64
## Configuration
Before using this script, you must configure the connection to the CBFTP API and the channels you want the bot to join.


1. In the script, update the **cb_api** variable with your CBFTP connection information:
```TCL
array set cb_api {
    "HOST"      "localhost"
    "PORT"      "55400"
    "PASSWORD"  "bestpass"
}

```
2. Similarly, update the chan_info variable with the channels you want the bot to join:
```TCL
array set chan_info {
    "SITENAME1"           {#ChanSite1 #ChanSite2}
    "SITENAME2"           {#ChanSite3}
}
```
1. Place the script in your /script/ directory
2. Edit your eggdrop configuration file (eggdrop.conf) and add at the bottom:.
```TCL
source scripts/cb_autoinvite.tcl

```
3. Restart or rehash your eggdrop
## Donation
If you find this script useful and it saves you time, please consider buying me a **coffee** or making a small **donation** to show your appreciation for the time I put into creating it and to encourage me to make more useful scripts. Visit https://github.com/ZarTek-Creole/DONATE

## My other codes
Feel free to browse through https://github.com/ZarTek-Creole to find other codes/projects that may be useful to you

## Bugs, Improvements
You can create a **ticket** on https://github.com/ZarTek-Creole/TCL_CBFTP-AUTOINVITE/issues

## Contribution
All contributions are welcome

---

# CBFTP Invite Bot Script (français)
Ce script permet à un bot Eggdrop de s'inviter automatiquement à des salons spécifiques sur les sites CBFTP auxquels il ne peut pas rejoindre en raison des modes +i (invitation) ou +k (clé).

**Un auto-invite par FTP via CBFTP API**

Il fait cela en utilisant l'interface HTTP de l'API CBFTP pour envoyer une demande d'invitation. Le sitebot sur le site CBFTP invitera alors automatiquement le bot sur le salon, lui permettant de rejoindre.

Ce script est particulièrement utile si vous exécutez votre bot Eggdrop derrière un ZNC, car il peut automatiquement se reconnecter aux salons de vos sites CBFTP après une déconnexion, un redémarrage ou tout autre événement qui vous fait perdre votre présence sur les salons.

# Prérequis
- Eggdrop 1.8 ou ultérieur
- Tcl 8.5 ou ultérieur
- cbftp avec l'API HTTP activé
- Les paquets Tcl suivants :
    - http
    - json
    - tls
    - base64

# Configuration
Avant d'utiliser ce script, vous devez configurer la connexion à l'API CBFTP et les salons auxquels vous voulez que le bot rejoigne.

1. Dans le script, mettez à jour la variable **cb_api** avec vos informations de connexion CBFTP :
```TCL
array set cb_api {
    "HOST"      "localhost"
    "PORT"      "55400"
    "PASSWORD"  "bestpass"
}

```
2. De même, mettez à jour la variable **chan_info** avec les salons auxquels vous voulez que le bot rejoigne :
```TCL
array set chan_info {
    "SITENAME1"           {#ChanSite1 #ChanSite2}
    "SITENAME2"           {#ChanSite3}
}

```
# Utilisation
Un classique ..
1. Mettre le script dans votre repertoire /script/
2. Editer votre fichier de configuration eggdrop.conf et mettre tout en bas:
```TCL
source scripts/cb_autoinvite.tcl
```
3. Redemarrer ou rehashez votre eggdrop.

# Donation
Vous trouvez ce script utile ? Il vous fait gagner du temps ? Pensez a me payer un café ou a me faire une petit donation pour le temps que j'ai consacrer et m'encourager a faire d'autres scripts utiles.
Visitez https://github.com/ZarTek-Creole/DONATE

# Mes autres codes
N'hesitez pas a fouiller sur https://github.com/ZarTek-Creole pour trouver d'autres codes / realisation qui pourrais vous êtes utile

# Bogue, Amelioration
Vous pouvez creer un ticket sur https://github.com/ZarTek-Creole/TCL_CBFTP-AUTOINVITE/issues

# Contribution
Toutes contribution est la bienvenu.

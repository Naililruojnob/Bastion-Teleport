# Installation et Configuration de Teleport

### Installation de Teleport

Pour installer Teleport, exécutez le script d'installation en remplaçant `<version>` par la version souhaitée :

```sh
sudo curl https://goteleport.com/static/install.sh | bash -s <version>
```

### Configuration de Teleport

1. **Création du fichier de configuration :**

   Utilisez la commande suivante pour configurer Teleport en créant un fichier de configuration :

   ```shell
   sudo teleport configure -o file --cluster-name=teleport.domaine.name
   ```

2. **Configuration derrière un reverse proxy :**

   Utilisez le fichier de configuration YAML suivant pour configurer Teleport derrière un reverse proxy. Assurez-vous d'adapter les domaines et les ports à votre environnement :

   ```yaml
   version: v3
   teleport:
     data_dir: /var/lib/teleport
     log:
       output: stderr
       severity: INFO
       format:
         output: text
     ca_pin: ""
     diag_addr: ""
   auth_service:
     enabled: true
     cluster_name: "teleport.example.com" # Mettez à jour avec votre domaine public
     listen_addr: 0.0.0.0:3025
     proxy_listener_mode: multiplex
     authentication:
       second_factor: on
       webauthn:
         rp_id: teleport.domaine.com # Mettez à jour avec votre domaine public
   ssh_service:
     enabled: true
     commands:
     - name: hostname
       command: [hostname]
       period: 1m0s
   proxy_service:
     enabled: true
     web_listen_addr: 0.0.0.0:3080
     public_addr: teleport.domaine.com:443 # Mettez à jour avec votre domaine public
     https_keypairs: []
     https_keypairs_reload_interval: 0s
     acme: {}
     trust_x_forwarded_for: true
   ```

   Pour plus de détails sur la configuration derrière un reverse proxy, consultez [ce guide](https://github.com/gravitational/teleport/discussions/26445).

### Démarrage automatique de Teleport

Activez le démarrage automatique de Teleport et démarrez-le :

```sh
sudo systemctl enable teleport
sudo systemctl start teleport
```

### Ajout d'un Utilisateur

Pour ajouter un utilisateur avec des rôles spécifiques, utilisez la commande suivante :

```sh
sudo tctl users add <name> --logins=<name>,root --roles=access,editor
```

Après la création de l'utilisateur, Teleport générera une URL pour que l'utilisateur définisse son mot de passe :

```
User "user" has been created but requires a password. Share this URL with the user to complete user setup, link is valid for 1h:
https://<proxy_host>:443/web/invite/<token>

NOTE: Make sure <proxy_host>:443 points at a Teleport proxy which users can access.
```

Cette URL permettra à l'utilisateur de définir son mot de passe et de commencer à utiliser Teleport.


Vous pouvez utiliser le script Teleport-Updater.sh pour mettre à jour votre Teleport.

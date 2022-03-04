# gp-day-2-setup

Dieses Skript generiert alle notwendigen Konfigurationen, Zertifikate, Verschlüsselungen, Dateien, ... welche für die Day-2-Operationen einer neuen Gepaplexx Umgebung benötigt werden. 

## Verwendung

**Voraussetzungen:**
- Tools
    - kubeseal (https://github.com/bitnami-labs/sealed-secrets#installation)
    - oc (https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html)
    - openssl (https://www.openssl.org/)
    - ansible-vault (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Konfiguration für die neue Umgebung (siehe [Konfiguration](#konfiguration))
- AnsibleVault-Passwort für das entsprechende Inventory

**Aufruf**  
- In gewünschtes Verzeichnis wechseln
- ```curl https://raw.githubusercontent.com/gattma/gp-day-2-setup/main/templates/config.properties.TEMPLATE > config.properties```  
- config.properties bearbeiten  
- ```docker run --rm -it -v $(pwd)/config.properties:/app/config.properties -v $(pwd)/generated:/app/generated ghcr.io/gattma/gp-day-2-setup:main config.properties```

## Was macht das Skript?

Dieses Skript nimmt alle Informationen aus der angegebenen [Konfiguration](#konfiguration) und generiert ein values.yaml welches vom day-2-operations/gp-cluster-setup Chart benötigt wird. Zusätzlich wird ein Key/Zertifikat-Paar für den SealedSecrets-Operater generiert und mit AnsibleVault verschlüsselt.

Folgende Schritte werden ausgeführt:

1. Verfügbarkeit der benötigten Tools wird überprüft: oc, kubeseal, openssl, ansible-vault
2. Erzeugen eines neuen privaten Keys und eines Zertifikats für den SealedSecrets-Operator
3. Key/Zertifikat aus Schritt 1 mithilfe von AnsibleVault verschlüsseln
4. Identity Provider 'Google' konfigurieren
    - Wenn ```ENABLE_GOOGLE_IP=true``` : Parameter für Google IP werden aus der Konfiguration in das finale values.yaml übernommen und mithilfe des in Schritt 1 erstellten Zertifikats verschlüsselt.
    - Wenn ```ENABLE_GOOGLE_IP=false```: Parameter für Google IP werden aus finalem values.yaml entfernt.
5. Identity Provider 'Git' konfigurieren
    - Wenn ```ENABLE_GIT_IP=true``` : Parameter für Git IP werden aus der Konfiguration in das finale values.yaml übernommen und mithilfe des in Schritt 1 erstellten Zertifikats verschlüsselt.
    - Wenn ```ENABLE_GIT_IP=false```: Parameter für Git IP werden aus finalem values.yaml entfernt.
6. Cluster Updater konfigurieren
    - Parameter ```SLACK_CHANNEL``` aus der Konfiguration wird base64 kodiert und in das finale values.yaml übernommen.
7. Cluster Config konfigurieren
    - Parameter ```ALERTMANAGER_CONFIG``` aus der Konfiguration wird mithilfe des in Schritt 1 erstelltem Zertifikats verschlüsselt und in das finale values.yaml übernommen.
8. Rook/Ceph konfigurieren
    - Rook/Ceph wird aktiviert/deaktiviert.
9. Cluster Logging konfigurieren
    - Cluster Logging wird aktiviert/deaktiviert.
10. Cluster Certificates konfigurieren
    - Parameter werden aus der Konfiguration übernommen und im finalen values.yaml gesetzt.
11. Console Patches konfigurieren
    - Parameter ```ROUTE_HOSTNAME``` wird aus der Konfiguration übernommen und im finalen values.yaml gesetzt.

## Konfiguration

Dazu muss zuerst eine neue Konfiguration für diese neue Umgebung angelegt werden. Eine Vorlage dazu befindet sich in templates/config.properties.TEMPLATE. Im folgenden werden die einzelnen Properties dieser Konfiguration erläutert:

- **ENV**: Name der neuen Umgebung (zBsp.: play, prod, ...)
- Identity Provider (siehe auch: TODO - URL zu Doku zum Anlegen einer neue Google/Git-App)
    - **ENABLE_GOOGLE_IP**: Soll Google als Identity Provider eingerichtet werden? Werte: true oder false
    - **GOOGLE_CLIENTSECRET**: Das ClientSecret welches beim Anlegen eines neuen OAuth 2 Clients in Google generiert wird.
    - **GOOGLE_CLIENTID**: Die ClientId welche beim Anlegen eines neuen OAuth 2 Clients in Google generiert wird. 
    - **GOOGLE_RESTRICTED_DOMAIN**: Die Domain auf die der Zugang eingeschränkt werden soll (zBsp.: gepardec.com).
    - **ENABLE_GIT_IP**: Soll Git als Identity Provider eingerichtet werden? Werte: true oder false 
    - **GIT_CLIENTSECRET**: Das ClientSecret welches beim Anlegen einer neuen OAuth App in Git generiert wird.
    - **GIT_CLIENTID**: Die ClientId welche beim Anlegen einer neuen OAuth App in Git generiert wird.
    - **GIT_RESTRICTED_ORGS**: Die Github Organisationen auf welche der Zugang eingeschränkt werden soll. Format: ["org1","org2"] (zBsp.: ["gepardec"]).
- Cluster Updater
    - **SLACK_CHANNEL**: In diesen Slack-Channel werden Informationen zu geplanten Cluster-Updates gepostet.
- Velero
    - **ENABLE_VELERO**: Soll Velero installiert werden? Werte: true oder false
    - TODO RESTLICHE 
- Cluster Config
    - **ALERTMANAGER_CONFIG**: Pfad zu einer YAML-Datei welche die Konfiguration für den Alertmanager enthält. Als Default wird die Konfiguration im Ordner templates verwendet.
- Rook/Ceph Instance
    - **ENABLE_ROOK_CEPH**: Soll Rook/Ceph installiert werden? Werte: true oder false
- Cluster Logging
    - **ENABLE_CLUSTER_LOGGING**: Soll Cluster Logging installiert werden? Werte: true oder false
- Certifacate Patches
    - **APISERVER_CUSTOMURL**: URL unter der die Openshift-API erreichbar sein soll (zBsp.: api.play.gepaplexx.com)
- Cluster Issuer (siehe auch: TODO URL zur Doku zum Anlegen eines neuen Route53-DNS in AWS)
    - **SOLVERS_DNS_ZONE**:
    - **SOLVERS_ACCESSKEYID**:
    - **SOLVERS_SECRETNAME**:
    - **SOLVERS_SECRETACCESSKEY**:
    - **CERTIFICATES_DEFAULTINGRESS**:
    - **CERTIFICATES_CONSOLE**:
    - **CERTIFICATES_API**:
- Console Patches
    - **ROUTE_HOSTNAME**:
# Установка elasticsearch + search-guard

## Пакеты

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update
apt install openjdk-8-jdk
apt-get install elasticsearch
```

## search-guard

Идём сюда https://search.maven.org/search?q=g:com.floragunn%20AND%20a:search-guard-6

Качаем zip

Кладём в /root/dist

Ставим

```
/usr/share/elasticsearch/bin/elasticsearch-plugin install -b file:///root/dist/search-guard-6-6.3.2-23.0.zip

```

## Сертификаты

Ищем https://search.maven.org/search?q=g:com.floragunn%20AND%20a:search-guard-tlstool

Распаковываем в /root/tools/search-guard-tlstool на одном сервере

### Конфигурация

https://docs.search-guard.com/latest/offline-tls-tool

Подготавливаем файл /root/tools/search-guard-tlstool/company.yml

```
###
### Self-generated certificate authority
###
#
# If you want to create a new certificate authority, you must specify its parameters here.
# You can skip this section if you only want to create CSRs
#
ca:
   root:
      # The distinguished name of this CA. You must specify a distinguished name.
      dn: CN=root.ca.company.com,OU=CA,O=COMPANY.,DC=company,DC=com

      # The size of the generated key in bits
      keysize: 2048

      # The validity of the generated certificate in days from now
      validityDays: 3650

      # Password for private key
      #   Possible values:
      #   - auto: automatically generated password, returned in config output;
      #   - none: unencrypted private key;
      #   - other values: other values are used directly as password
      pkPassword: Пароль1

      # The name of the generated files can be changed here
      file: root-ca.pem

   # If you want to use an intermediate certificate as signing certificate,
   # please specify its parameters here. This is optional. If you remove this section,
   # the root certificate will be used for signing.
   intermediate:
      # The distinguished name of this CA. You must specify a distinguished name.
      dn: CN=root.ca.dev.company.com,OU=CA,O=COMPANY Dev.,DC=company,DC=com

      # The size of the generated key in bits
      keysize: 2048

      # The validity of the generated certificate in days from now
      validityDays: 3650

      pkPassword: Пароль2

      # If you have a certificate revocation list, you can specify its distribution points here
      # crlDistributionPoints: URI:https://raw.githubusercontent.com/floragunncom/unittest-assets/master/revoked.crl

###
### Default values and global settings
###
defaults:

      # The validity of the generated certificate in days from now
      validityDays: 3650

      # Password for private key
      #   Possible values:
      #   - auto: automatically generated password, returned in config output;
      #   - none: unencrypted private key;
      #   - other values: other values are used directly as password
      pkPassword: Пароль3

      # Specifies to recognize legitimate nodes by the distinguished names
      # of the certificates. This can be a list of DNs, which can contain wildcards.
      # Furthermore, it is possible to specify regular expressions by
      # enclosing the DN in //.
      # Specification of this is optional. The tool will always include
      # the DNs of the nodes specified in the nodes section.
      #nodesDn:
      #- "CN=*.example.com,OU=Ops,O=Example Com\\, Inc.,DC=example,DC=com"
      # - 'CN=node.other.com,OU=SSL,O=Test,L=Test,C=DE'
      # - 'CN=*.example.com,OU=SSL,O=Test,L=Test,C=DE'
      # - 'CN=elk-devcluster*'
      # - '/CN=.*regex/'

      # If you want to use OIDs to mark legitimate node certificates,
      # the OID can be included in the certificates by specifying the following
      # attribute

      # nodeOid: "1.2.3.4.5.5"

      # The length of auto generated passwords
      # generatedPasswordLength: 12

      # Set this to true in order to generate config and certificates for
      # the HTTP interface of nodes
      httpsEnabled: true

      # Set this to true in order to re-use the node transport certificates
      # for the HTTP interfaces. Only recognized if httpsEnabled is true

      # reuseTransportCertificatesForHttp: false

      # Set this to true to enable hostname verification
      #verifyHostnames: false

      # Set this to true to resolve hostnames
      #resolveHostnames: false


###
### Nodes
###
#
# Specify the nodes of your ES cluster here
#
nodes:
  - name: elastic1
    dn: CN=elastic1.company.com,OU=Ops,OU=CA,O=COMPANY Dev.,DC=company,DC=com
    dns: elastic1.company.com
    ip: xx.xx.xx.xx
  - name: elastic2
    dn: CN=elastic2.company.com,OU=Ops,OU=CA,O=COMPANY Dev.,DC=company,DC=com
    dns: elastic2.company.com
    ip: xx.xx.xx.xy
  - name: elastic3
    dn: CN=elastic3.company.com,OU=Ops,OU=CA,O=COMPANY Dev.,DC=company,DC=com
    dns: elastic3.company.com
    ip: xx.xx.xx.yy


###
### Clients
###
#
# Specify the clients that shall access your ES cluster with certificate authentication here
#
# At least one client must be an admin user (i.e., a super-user). Admin users can
# be specified with the attribute admin: true
#
clients:
  - name: client
    dn: CN=client.example.com,OU=Ops,O=COMPANY Dev.,DC=company,DC=com
  - name: admin
    dn: CN=admin.example.com,OU=Ops,O=COMPANY Dev.,DC=company,DC=com
    admin: true

```

Сгенерировать сертификаты:

```
./tools/sgtlstool.sh -c config/company.yml -ca -crt
```

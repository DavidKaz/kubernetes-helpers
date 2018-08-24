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

### Конфигурация сертификатов

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

Должно получиться следующее

```
root@elastic1 ~/tools/search-guard-tlstool # ls -al out/
total 104
drwxr-xr-x 2 root root 4096 Aug 24 14:07 .
drwxr-xr-x 6 root root 4096 Aug 24 12:03 ..
-rw-r--r-- 1 root root 1801 Aug 24 14:07 admin.key
-rw-r--r-- 1 root root 3156 Aug 24 14:07 admin.pem
-rw-r--r-- 1 root root  294 Aug 24 14:07 client-certificates.readme
-rw-r--r-- 1 root root 1801 Aug 24 14:07 client.key
-rw-r--r-- 1 root root 3156 Aug 24 14:07 client.pem
-rw-r--r-- 1 root root 1410 Aug 24 14:07 elastic1_elasticsearch_config_snippet.yml
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic1_http.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic1_http.pem
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic1.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic1.pem
-rw-r--r-- 1 root root 1410 Aug 24 14:07 elastic2_elasticsearch_config_snippet.yml
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic2_http.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic2_http.pem
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic2.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic2.pem
-rw-r--r-- 1 root root 1410 Aug 24 14:07 elastic3_elasticsearch_config_snippet.yml
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic3_http.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic3_http.pem
-rw-r--r-- 1 root root 1801 Aug 24 14:07 elastic3.key
-rw-r--r-- 1 root root 3254 Aug 24 14:07 elastic3.pem
-rw-r--r-- 1 root root 1801 Aug 14 15:03 root-ca.key
-rw-r--r-- 1 root root 1371 Aug 14 15:03 root-ca.pem
-rw-r--r-- 1 root root 1801 Aug 14 15:03 signing-ca.key
-rw-r--r-- 1 root root 1562 Aug 14 15:03 signing-ca.pem
```

root-ca.pem надо будет добавить всем клиентам, чтобы могли без ошибок подключаться к серверам.


### Конфигурация search-guard

Настройки хранятся в индексе elastic, заливаются туда с помощью sgadmin, поэтому делать только на одной ноде.

Изначально searchguard никак не сконфигурирован, используются настройки подготовленные на основе demo установки:

sg_action_groups.yml - без изменений

```
---
UNLIMITED:
  readonly: true
  permissions:
  - "*"
INDICES_ALL:
  readonly: true
  permissions:
  - "indices:*"
ALL:
  readonly: true
  permissions:
  - "INDICES_ALL"
MANAGE:
  readonly: true
  permissions:
  - "indices:monitor/*"
  - "indices:admin/*"
CREATE_INDEX:
  readonly: true
  permissions:
  - "indices:admin/create"
  - "indices:admin/mapping/put"
MANAGE_ALIASES:
  readonly: true
  permissions:
  - "indices:admin/aliases*"
MONITOR:
  readonly: true
  permissions:
  - "INDICES_MONITOR"
INDICES_MONITOR:
  readonly: true
  permissions:
  - "indices:monitor/*"
DATA_ACCESS:
  readonly: true
  permissions:
  - "indices:data/*"
  - "CRUD"
WRITE:
  readonly: true
  permissions:
  - "indices:data/write*"
  - "indices:admin/mapping/put"
READ:
  readonly: true
  permissions:
  - "indices:data/read*"
  - "indices:admin/mappings/fields/get*"
DELETE:
  readonly: true
  permissions:
  - "indices:data/write/delete*"
CRUD:
  readonly: true
  permissions:
  - "READ"
  - "WRITE"
SEARCH:
  readonly: true
  permissions:
  - "indices:data/read/search*"
  - "indices:data/read/msearch*"
  - "SUGGEST"
SUGGEST:
  readonly: true
  permissions:
  - "indices:data/read/suggest*"
INDEX:
  readonly: true
  permissions:
  - "indices:data/write/index*"
  - "indices:data/write/update*"
  - "indices:admin/mapping/put"
  - "indices:data/write/bulk*"
GET:
  readonly: true
  permissions:
  - "indices:data/read/get*"
  - "indices:data/read/mget*"
CLUSTER_ALL:
  readonly: true
  permissions:
  - "cluster:*"
CLUSTER_MONITOR:
  readonly: true
  permissions:
  - "cluster:monitor/*"
CLUSTER_COMPOSITE_OPS_RO:
  readonly: true
  permissions:
  - "indices:data/read/mget"
  - "indices:data/read/msearch"
  - "indices:data/read/mtv"
  - "indices:data/read/coordinate-msearch*"
  - "indices:admin/aliases/exists*"
  - "indices:admin/aliases/get*"
  - "indices:data/read/scroll"
CLUSTER_COMPOSITE_OPS:
  readonly: true
  permissions:
  - "indices:data/write/bulk"
  - "indices:admin/aliases*"
  - "indices:data/write/reindex"
  - "CLUSTER_COMPOSITE_OPS_RO"
MANAGE_SNAPSHOTS:
  readonly: true
  permissions:
  - "cluster:admin/snapshot/*"
  - "cluster:admin/repository/*"
```

sg_config.yml - убраны все лишние authc, совсем выпилен authz

```
---
searchguard:
  dynamic:
    http:
      anonymous_auth_enabled: false
      xff:
        enabled: false
        internalProxies: "192\\.168\\.0\\.10|192\\.168\\.0\\.11"
        remoteIpHeader: "x-forwarded-for"
        proxiesHeader: "x-forwarded-by"
    authc:
      basic_internal_auth_domain:
        http_enabled: true
        transport_enabled: true
        order: 1
        http_authenticator:
          type: "basic"
          challenge: true
        authentication_backend:
          type: "intern"
```

sg_internal_users.yml - всем пользователям поменять хеши паролей с помощью /usr/share/elasticsearch/plugins/search-guard-6/tools/hash.sh , добавлен пользователь monitor с ролью monitor
```
---
admin:
  readonly: true
  hash: "hash"
  roles:
  - "admin"
  attributes:
    attribute1: "value1"
    attribute2: "value2"
    attribute3: "value3"
logstash:
  hash: "hash"
  roles:
  - "logstash"
kibanaserver:
  readonly: true
  hash: "hash"
kibanaro:
  hash: "hash"
  roles:
  - "kibanauser"
  - "readall"
readall:
  hash: "hash"
  roles:
  - "readall"
snapshotrestore:
  hash: "hash"
  roles:
  - "snapshotrestore"
monitor:
  hash: "hash"
  roles:
  - "monitor"
```

sg_roles_mapping.yml - пользователь monitor добавлен в роли sg_kibana_server, sg_monitor https://docs.search-guard.com/latest/search-guard-xpack-monitoring по ссылке написано делать по-другому, но получилось только так
```
---
sg_all_access:
  readonly: true
  backendroles:
  - "admin"
sg_logstash:
  backendroles:
  - "logstash"
sg_kibana_server:
  readonly: true
  users:
  - "kibanaserver"
  - "monitor"
sg_kibana_user:
  backendroles:
  - "kibanauser"
sg_readall:
  readonly: true
  backendroles:
  - "readall"
sg_manage_snapshots:
  readonly: true
  backendroles:
  - "snapshotrestore"
sg_own_index:
  users:
  - "*"
sg_monitor:
  users:
  - "monitor"
```

sg_roles.yml - без изменений
```
---
sg_all_access:
  readonly: true
  cluster:
  - "UNLIMITED"
  indices:
    '*':
      '*':
      - "UNLIMITED"
  tenants:
    admin_tenant: "RW"
sg_readall:
  readonly: true
  cluster:
  - "CLUSTER_COMPOSITE_OPS_RO"
  indices:
    '*':
      '*':
      - "READ"
sg_readall_and_monitor:
  cluster:
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS_RO"
  indices:
    '*':
      '*':
      - "READ"
sg_kibana_user:
  readonly: true
  cluster:
  - "INDICES_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  indices:
    ?kibana:
      '*':
      - "MANAGE"
      - "INDEX"
      - "READ"
      - "DELETE"
    ?kibana-6:
      '*':
      - "MANAGE"
      - "INDEX"
      - "READ"
      - "DELETE"
    '*':
      '*':
      - "indices:data/read/field_caps*"
sg_kibana_server:
  readonly: true
  cluster:
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  - "cluster:admin/xpack/monitoring*"
  - "indices:admin/template*"
  indices:
    ?kibana:
      '*':
      - "INDICES_ALL"
    ?kibana-6:
      '*':
      - "INDICES_ALL"
    ?reporting*:
      '*':
      - "INDICES_ALL"
    ?monitoring*:
      '*':
      - "INDICES_ALL"
sg_logstash:
  cluster:
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  - "indices:admin/template/get"
  - "indices:admin/template/put"
  indices:
    logstash-*:
      '*':
      - "CRUD"
      - "CREATE_INDEX"
    '*beat*':
      '*':
      - "CRUD"
      - "CREATE_INDEX"
sg_manage_snapshots:
  cluster:
  - "MANAGE_SNAPSHOTS"
  indices:
    '*':
      '*':
      - "indices:data/write/index"
      - "indices:admin/create"
sg_own_index:
  cluster:
  - "CLUSTER_COMPOSITE_OPS"
  indices:
    ${user_name}:
      '*':
      - "INDICES_ALL"
sg_xp_monitoring:
  readonly: true
  indices:
    ?monitor*:
      '*':
      - "INDICES_ALL"
sg_xp_alerting:
  readonly: true
  cluster:
  - "indices:data/read/scroll"
  - "cluster:admin/xpack/watcher*"
  - "cluster:monitor/xpack/watcher*"
  indices:
    ?watches*:
      '*':
      - "INDICES_ALL"
    ?watcher-history-*:
      '*':
      - "INDICES_ALL"
    ?triggered_watches:
      '*':
      - "INDICES_ALL"
    '*':
      '*':
      - "READ"
      - "indices:admin/aliases/get"
sg_xp_machine_learning:
  readonly: true
  cluster:
  - "cluster:admin/persistent*"
  - "cluster:internal/xpack/ml*"
  - "indices:data/read/scroll*"
  - "cluster:admin/xpack/ml*"
  - "cluster:monitor/xpack/ml*"
  indices:
    '*':
      '*':
      - "READ"
      - "indices:admin/get*"
    ?ml-*:
      '*':
      - "*"
sg_readonly_and_monitor:
  cluster:
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS_RO"
  indices:
    '*':
      '*':
      - "READ"
sg_monitor:
  cluster:
  - "cluster:admin/xpack/monitoring/*"
  - "cluster:admin/ingest/pipeline/put"
  - "cluster:admin/ingest/pipeline/get"
  - "indices:admin/template/get"
  - "indices:admin/template/put"
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  indices:
    ?monitor*:
      '*':
      - "INDICES_ALL"
    ?marvel*:
      '*':
      - "INDICES_ALL"
    ?kibana*:
      '*':
      - "READ"
    '*':
      '*':
      - "indices:data/read/field_caps"
sg_alerting:
  cluster:
  - "indices:data/read/scroll"
  - "cluster:admin/xpack/watcher/watch/put"
  - "cluster:admin/xpack/watcher*"
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  indices:
    ?kibana*:
      '*':
      - "READ"
    ?watches*:
      '*':
      - "INDICES_ALL"
    ?watcher-history-*:
      '*':
      - "INDICES_ALL"
    ?triggered_watches:
      '*':
      - "INDICES_ALL"
    '*':
      '*':
      - "READ"
```

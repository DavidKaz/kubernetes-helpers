# Установка и настройка filebeat/metricbeat для сбора данных в elasticsearch с приложений и кластера kubernetes

## elasticsearch

Используются elasticsearch+searhguard устанновленные по инструкции https://github.com/DavidKaz/kubernetes-helpers/blob/master/howtos/elasticsearch-searchguard/es-sg.md

Созданы пользователи filebeat и grafana:

* sg_internal_users.yml
```
filebeat:
  hash: "хэш"
  roles:
  - "filebeat"
grafana:
  hash: "хэш"
  roles:
  - "grafana"
```

Созданы роли sg_filebeat и sg_grafana
(FIXME: grafana для успешного запуска "test and add connection" понадобилось слишком много прав):

* sg_roles.yml
```
sg_filebeat:
  cluster:
  - "CLUSTER_MONITOR"
  - "CLUSTER_COMPOSITE_OPS"
  - "indices:admin/template/get"
  - "indices:admin/template/put"
  indices:
    '*beat*':
      '*':
      - "CRUD"
      - "CREATE_INDEX"
sg_grafana:
  readonly: true
  indices:
    filebeat-*:
      '*':
      - "INDICES_ALL"
    metricbeat-*:
      '*':
      - "INDICES_ALL"
```
* sg_roles_mapping.yml
```
sg_filebeat:
  backendroles:
  - "filebeat"
sg_grafana:
  readonly: true
  backendroles:
  - "grafana"
```

## redis

Используется master-slave установка redis https://github.com/flant/kube-redis, поэтому мониторится только master:
В helm chart добавляется deployment metricbeat собирающий данные с redis. kubernetes.namespace - добавляем значение из переменных helm, так сам redis про это ничего не знает.
В root-ca.pem должен быть корневой сертификат сгенерированный при установке elasticsearch.

## rabbit

В helm chart добавляется deployment metricbeat собирающий данные с rabbit. kubernetes.namespace - также добавляем значение из переменной из helm.
В root-ca.pem должен быть корневой сертификат сгенерированный при установке elasticsearch.

## filebeat

Сбор логов с подов kubernetes. За основу взят чарт из репозитория  https://github.com/helm/charts.git

### Приложения nodejs

Логи как правило в json, поэтому разбираем message в json в поле applog с помощью decode_json_fields.
Далее, так как в логах структура неупорядочена, и структура полученного json в applog меняется от лога к логу, то берём только несколько полей, копируя иx в application: inProgress, res.statusCode, duration, name. Задаём формат этих полей в шаблоне директивами setup.template.overwrite: true, setup.template.append_fields:.

### Приложения frontend

Это nginx с форматом лога:
```
  log_format jsonlog escape=json '{ "timeiso8601": "$time_iso8601", '
    '"host": "$host", '
    '"remote_addr": "$remote_addr", '
    '"remote_user": "$remote_user", '
    '"body_bytes_sent": "$body_bytes_sent", '
    '"request_time": "$request_time", '
    '"status": "$status", '
    '"request_uri": "$uri", '
    '"X-Amzn-Trace-Id": "$http_x_amzn_trace_id", '
    '"request_method": "$request_method", '
    '"redirect": "$sent_http_location", '
    '"protocol": "$server_protocol", '
    '"http_referrer": "$http_referer", '
    '"http_user_agent": "$http_user_agent" }';
```

json лог из message разбирается как json в applog и копируется в frontend. Формат полей описан в setup.template.append_fields:.

### nginx-ingress

Это nginx с форматом лога:
```
log_format jsonlog escape=json '{ "time": "$time_iso8601", "request_id": "$request_id", "user":
    "$remote_user", "address": "$the_real_ip", "bytes_received": $request_length,
    "bytes_sent": $bytes_sent, "protocol": "$server_protocol", "scheme": "$scheme",
    "method": "$request_method", "host": "$host", "path": "$uri", "request_query":
    "$args", "referrer": "$http_referer", "user_agent": "$http_user_agent", "request_time":
    $request_time, "status": $status, "content_kind": "$content_kind", "upstream_response_time":
    $total_upstream_response_time, "upstream_retries": $upstream_retries, "namespace":
    "$namespace", "ingress": "$ingress_name", "service": "$service_name", "service_port":
    "$service_port", "vhost": "$server_name", "location": "$location_path", "nginx_upstream_addr":
    "$upstream_addr", "nginx_upstream_response_length": "$upstream_response_length",
    "nginx_upstream_response_time": "$upstream_response_time", "nginx_upstream_status":
    "$upstream_status" }'
```
json лог из message разбирается как json в applog и копируется в loadbalancer. Формат полей описан в setup.template.append_fields:.

## metricbeat

Сбор метрик с kube-state-metrics, kubelet, system.

За основу взят kube-state-metrics + туда добавлены metricbeat deployment и daemonset из https://github.com/elastic/beats/tree/master/deploy/kubernetes/metricbeat

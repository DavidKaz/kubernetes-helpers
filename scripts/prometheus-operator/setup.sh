helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring -f prometheus-operator-values.yaml
helm install coreos/kube-prometheus --name kube-prometheus --namespace monitoring -f kube-prometheus-values.yaml
helm install coreos/grafana --name grafana --namespace monitoring -f grafana-values.yaml

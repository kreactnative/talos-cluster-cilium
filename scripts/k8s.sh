#!/bin/bash
export KUBECONFIG=$HOME/.kube/talos-ha-cilium-config
kubectl config current-context
#kubectl apply -f k8s/matallb-ns.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
sleep 30
istioctl install -f k8s/istio-operator.yaml -y
sleep 20
kubectl apply -f k8s/istio-brotli.yaml
kubectl apply -f k8s/istio-secure-header.yaml
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io metallb-webhook-configuration
kubectl apply -f metallb.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack \
  --create-namespace \
  --namespace kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=false

kubectl rollout restart deployment/metrics-server -n kube-system
kubectl rollout restart deployment/controller -n metallb-system
kubectl rollout restart deployment/hubble-relay -n cilium
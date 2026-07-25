output "grafana_service_name" {
  value = kubernetes_service.grafana.metadata[0].name
}

output "prometheus_service_name" {
  value = kubernetes_service.prometheus.metadata[0].name
}

output "jaeger_service_name" {
  value = kubernetes_service.jaeger.metadata[0].name
}

local k = import "kausal.libsonnet";

k {
  local container = $.core.v1.container,

  node_exporter_container::
    container.new("node-exporter", $._images.nodeExporter) +
    container.withPorts($.core.v1.containerPort.new("http-metrics", 9100)) +
    container.withArgs([
      "--path.procfs=/host/proc",
      "--path.sysfs=/host/sys",
      "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)",
    ]) +
    container.mixin.securityContext.withPrivileged(true) +
    $.util.resourcesRequests("10m", "20Mi") +
    $.util.resourcesLimits("20m", "40Mi"),

  local daemonSet = $.extensions.v1beta1.daemonSet,

  node_exporter_deamonset:
    daemonSet.new("node-exporter", [$.node_exporter_container]) +
    daemonSet.mixin.spec.template.spec.withHostPid(true) +
    daemonSet.mixin.spec.template.spec.withHostNetwork(true) +
    $.util.hostVolumeMount("proc", "/proc", "/host/proc") +
    $.util.hostVolumeMount("sys", "/sys", "/host/sys") +
    $.util.hostVolumeMount("root", "/", "/rootfs"),
}

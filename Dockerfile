ARG VCLUSTER_PRO_VERSION
ARG K8S_VERSION
FROM registry.k8s.io/kube-controller-manager:${K8S_VERSION} AS kube-controller-manager

FROM registry.k8s.io/kube-apiserver:${K8S_VERSION} AS kube-apiserver

FROM registry.k8s.io/kube-scheduler:${K8S_VERSION} AS kube-scheduler

FROM ghcr.io/loft-sh/vcluster-pro:${VCLUSTER_PRO_VERSION}

COPY --from=kube-controller-manager /usr/local/bin/kube-controller-manager /binaries/kube-controller-manager
COPY --from=kube-apiserver /usr/local/bin/kube-apiserver /binaries/kube-apiserver
COPY --from=kube-scheduler /usr/local/bin/kube-scheduler /binaries/kube-scheduler

# switch to root to ensure necessary permissions
USER root

RUN addgroup -g 998 loft && \
	adduser -S -u 998 -h /home/loft -s /bin/sh -g loft loft && \
  mkdir -p -m 777 /home/loft/cache && \
  chown -R loft:loft /home/loft/cache
  
ENV XDG_CACHE_HOME="/home/loft/cache" 

# Switch to loft user
USER 998

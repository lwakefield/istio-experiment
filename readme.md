Takes ~15m to spin up a cluster w/ terraform.

```
AWS_PROFILE=tm-staging aws --region=us-west-1 eks update-kubeconfig --name cluster

# get istio locally w/ and use the local files in the next few steps
curl -L https://istio.io/downloadIstio | sh -

kc create namespace istio-system
helm install istio-base manifests/charts/base -n istio-system
helm install istiod manifests/charts/istio-control/istio-discovery -n istio-system
helm install istio-ingress manifests/charts/gateways/istio-ingress -n istio-system

kc apply -f ./foo.yaml
kc apply -f ./bar.yaml
kc apply -f ./foobar.yaml
kc apply -f ./raboof.yaml
kc apply -f ./cli.yaml

# get the DNS for the ALB created by the istio-discovery chart (ingressgateway)
kc get svc -nistio-system

# then you can make requests that will be routed by istio/envoy
curl -v -H 'host: raboof.svc' a44b71722571448faabc2c0d644ab923-1960108828.us-west-1.elb.amazonaws.com/bar
```

I still need to wrap my head around the finer points of IngressGateway (sets up ALB, but what else is it doing?) vs. Gateway (announces a host that has ingress/egress, but does no routing until a VirtualService is configured) vs. VirtualService (this is where the routing fun happens).

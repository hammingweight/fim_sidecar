# Kubernetes Manifests
This example manifests declare two Kubernetes resources: A [pod](./hello_server_pod.yaml) and a [load balancer service](./hello_load_balancer_service.yaml) that makes
the pod externally accessible.

## `hello_server_pod`
The `hello_server_pod` has two containers:
* A "Hello, world" HTTP server
* A `fim` sidecar that monitors the integrity of an `index.html` file deployed in the application

The pod overrides the default value of `shareProcessNamespace` and sets it to [true](https://github.com/hammingweight/fim_sidecar/blob/ed219a82efb2e2e4fa68dd33996fb09aee22e91e/k8s_resources/hello_server_pod.yaml#L11) so that the application and
sidecar processes share the same process namespace; i.e. you can view the processes in both containers from either container.

The `fim` container runs with the [`CAP SYS_PTRACE` capability](https://github.com/hammingweight/fim_sidecar/blob/8f0c7f30011abb509ff219b0d0eadfc0deea0175/k8s_manifests/hello_server_pod.yaml#L39) so that the container
can view all files in the `hello_server` container which is necessary to check the integrity of the files. The container runtime also adds capabilities to override discretionary access control and to kill processes to the `fim` container.

The `fim` container has a [`livenessProbe`](https://github.com/hammingweight/fim_sidecar/blob/1acc0a8bb9f62c8f3dd06c80b3d9defaf931588b/k8s_manifests/hello_server_pod.yaml#L34) that checks the integrity of the `index.html` file.

## `hello_load_balancer_service`
The `hello_load_balancer_service` service is a simple Load Balancer service that routes requests on port 80 to port 8000 of the `hello_server` container.

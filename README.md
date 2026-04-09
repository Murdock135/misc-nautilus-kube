# misc-nautilus-kube

## RTFM

Please read this the instructions on [nrp.ai](https://nrp.ai/documentation/userdocs/start/getting-started/) before proceeding.

## Pre-setup
Put the names of all namespaces you need access to in the `namespaces.txt` file, one per line. This will be used by the `check_cluster_access.sh` script to verify that you have access to all required namespaces.

## Setup

1. Install kubectl (writes `/usr/local/bin/kubectl` and downloads temporary files into the current directory while running):
	```sh
	bash install_kubectl.sh
	```

2. Install kubelogin (writes `~/.local/bin/kubectl-oidc_login`):
	```sh
	bash install_kubelogin.sh
	```

3. Download your kubeconfig file (creates `~/.kube/` if needed and writes `~/.kube/config`):
	```sh
	bash make_config.sh
	```

4. Check that the Nautilus context exists and is set (modifies your current kubectl context):
	```sh
	bash check_config.sh
	```

5. List all cluster nodes (this does not write files, but it will launch your browser for authentication if you are not already logged in):
	```sh
	bash bin/get_nodes.sh
	```

6. Check access to all required namespaces (this does not create or modify files):
	```sh
	bash bin/check_cluster_access.sh
	```

-- END --
# misc-nautilus-kube

## RTFM

Please read this the instructions on [nrp.ai](https://nrp.ai/documentation/userdocs/start/getting-started/) before proceeding.

## Pre-setup
Put the names of all namespaces you need access to in the `namespaces.txt` file, one per line. This will be used by the `check_cluster_access.sh` script to verify that you have access to all required namespaces.

## Setup

1. Install kubectl:
	```sh
	bash install_kubectl.sh
	```

2. Install kubelogin:
	```sh
	bash install_kubelogin.sh
	```

3. Download your kubeconfig file:
	```sh
	bash make_config.sh
	```

4. Check that the Nautilus context exists and is set:
	```sh
	bash bin/check_config.sh
	```

5. Check access to all required namespaces:
	```sh
	bash bin/check_cluster_access.sh
	```

6. List all cluster nodes (This will launch your browser for authentication if you are not already logged in):
	```sh
	bash bin/get_nodes.sh
	```

-- END --
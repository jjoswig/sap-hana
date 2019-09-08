#!/bin/sh
source ~/Desktop/set-sp_private.sh

cd ~/Desktop/sap-hana/deploy/vm/modules/single_node_hana/

for OUTPUT in $(cat terraform.tfvars | grep -Eo '(http|https)://[^"]+')
do
	if [ `curl -I $OUTPUT 2>/dev/null | head -n 1 | cut -d$' ' -f2` -eq 200 ]; then
		:
	else
		echo $OUTPUT could not be downloaded
		exit -1
	fi

done

terraform apply -auto-approve

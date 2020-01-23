## Scripts

build.sh - Locally builds the containers
scale.sh - Runs the correct containers to scale the cluster 
 - 1) edit config.json to add/remove the nodes
 - 2) if removing a node, drain and delete the node in OpenShift
 - 3) Run scale.sh on the bastion


## Making a release

Before making a release, the TAG variable needs to be updated in build.sh

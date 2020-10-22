#!/usr/bin/env python3

import yaml
import json
import argparse

def Vars():
    '''
    Reads vars.yml file to populate domain, api and name variables

    Outputs:
        name: Name of the host to be set up in opsview.
        domaain: Domain suffix of openshift cluster.
        api: API address of openshift cluster.
    '''
    with open('vars.yml') as f:
        data = yaml.load(f)

    domain = data['domainSuffix']
    api = 'api.{}'.format(domain)
    name = data['opsviewName'] 

    return domain, api, name

def generateJson(domain, api, name):
    metadata = {}

    metadata['alias'] = ""
    metadata['check_command'] = "Always assumed to be UP"
    metadata['variables'] = []
    metadata['host_group'] = {"name": "UKCloud OpenShift"}
    metadata['host_templates'] = [{"name": "UKCloud OpenShift"}]  
    metadata['fqdn'] = api
    metadata['monitored_by'] = "assured COR internet bubble collector group"
    metadata['name'] = name

    variables = metadata['variables']
    variables.append({"name": "OPENSHIFT_API", "value": api})
    variables.append({"name": "OPENSHIFT_DOMAIN_SUFFIX", "value": domain})
    variables.append({"name": "OPENSHIFT_PORT", "value": "6443"})
    variables.append({"name": "OPENSHIFT_TOKEN", "value": "Monitoring token", "arg1": "secret(label=monitoring_auth_token)"})

    routeList = {
                 "oauth-openshift.apps": "403", "console-openshift-console.apps": "200", "downloads-openshift-console.apps": "200",
                 "kibana-openshift-logging.apps": "403", "alertmanager-main-openshift-monitoring.apps": "403", "grafana-openshift-monitoring.apps": "403",
                 "prometheus-k8s-openshift-monitoring.apps": "403", "thanos-querier-openshift-monitoring.apps": "403"
                }

    for prefix, returnCode in routeList.items():
        value = prefix.split('-')[0]
        variables.append({"name": "OPENSHIFT_URL", "value": value, "arg1": prefix, "arg2": returnCode})
  
    metadataJson = json.dumps(metadata, indent=4)
    print(metadataJson)

d, a, n = Vars()

generateJson(d, a, n)
    
    
    


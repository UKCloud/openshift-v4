#!/usr/bin/env python3

import json
import argparse

def argVars():
    parser = argparse.ArgumentParser(description='Generate metadata for v3 and v4 clusters.')
    parser.add_argument('--version', required=True, help='3.9, 3.10, 3.11 or 4')
    parser.add_argument('--domain', required=True, help='Domain suffix of cluster', type=str)
    parser.add_argument('--name', required=True, help='Name of host in opsview', type=str)
    args = parser.parse_args()

    version = args.version
    name = args.name
    domain = args.domain

    if version == '4':
        api = 'api.{}'.format(domain)
        port = 6443
    else:
        api = 'ocp.{}'.format(domain)
        port = 8443
       

    return version, domain, api, name, port

def generateJson(version, domain, api, name, port):
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
    variables.append({"name": "OPENSHIFT_PORT", "value": port})
    variables.append({"name": "OPENSHIFT_TOKEN", "value": "Monitoring token", "arg1": "secret(label=monitoring_auth_token)"})

    if version == '4':
        routeList = {
                     "oauth-openshift.apps": "403", "console-openshift-console.apps": "200", "downloads-openshift-console.apps": "200",
                     "kibana-openshift-logging.apps": "403", "alertmanager-main-openshift-monitoring.apps": "403", "grafana-openshift-monitoring.apps": "403",
                     "prometheus-k8s-openshift-monitoring.apps": "403", "thanos-querier-openshift-monitoring.apps": "403"
                    }
    elif version == '3.11':
        routeList = {
                     "registry": "200", "console": "200", "hawkular-metrics": "200",
                     "kibana": "302", "alertmanager": "403", "grafana": "403",
                     "prometheus": "403"
                    }
    elif version == '3.10':
        routeList = {
                     "hawkular-metrics": "200", "kibana": "302"
                    }
    elif version == '3.9':
        routeList = {
                     "hawkular-metrics": "200", "kibana": "302"
                    }

    for prefix, returnCode in routeList.items():
        value = prefix.split('-')[0]
        variables.append({"name": "OPENSHIFT_URL", "value": value, "arg1": prefix, "arg2": returnCode})
  
        

    metadataJson = json.dumps(metadata, indent=4)
    print(metadataJson)

v, d, a, n, p = argVars()

generateJson(v, d, a, n, p)
    
    
    


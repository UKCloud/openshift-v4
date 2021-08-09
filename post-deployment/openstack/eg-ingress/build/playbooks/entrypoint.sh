export K8S_AUTH_VERIFY_SSL=no

# Add uid to /etc/passwd to allow Ansible to run
if [ `id -u` -ge 500 ]; then
    echo "runner:x:`id -u`:`id -g`:,,,:/runner:/bin/bash" > /tmp/passwd
    cat /tmp/passwd >> /etc/passwd
    rm /tmp/passwd
fi

ansible-playbook /usr/local/playbooks/update_eg_loadbalancer_members.yaml

variable "worker_user_data" {
  type = string
  default = <<EOF
#cloud-config
runcmd:
  - ['echo', 'placeholder']
write_files:
  - content: |
         placeholder
    path: /etc/systemd/system/kubelet.service.d/manifest.conf
runcmd:
  - ['rm', '-f', '/etc/cni/net.d/100-crio-bridge.conf']
  - ['aws', 's3', 'cp', 's3://cluster0-lockbox/bin/cluster_bootstrap.py', '/usr/local/bin/cluster_bootstrap.py' ]
  - ['chmod', 'a+x', '/usr/local/bin/cluster_bootstrap.py']
  - ['/usr/local/bin/cluster_bootstrap.py', 'worker']
users:
  - name: valentine
    groups: wheel
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys: 
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCubn3cK1NsOS448/IxSHxMI3/2bleerz/GxR/qA/fn+9R6V6wuhRP+MH/WHb3xW+hT67yfjCG5aKrG8HAeeHYpewVW/NR8OGq/JUNzRr1apRbpe0dxHrUu/rqzF5KGLCbKkt5UfJDWlx3aXCwMU9IUSgK87me4bm9QbnKNZ22LxZNCqApqF5bwXa0Ufs3pGxU7CGcvNk9v0shss86x6bn0BltyvlguZ5SLqAWQWjJlXaRmtBoYVCUWhj2XtVgqB4pIyM463IjFQ9ifHAwRMankQI4Z7nopfZjnuq/9lwd+zMfonsed4v2T5lMDU2ar6hLV+JETgidyjF2y8kGHvv8T
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
  - bash
EOF
}

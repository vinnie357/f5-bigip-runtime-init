#!/bin/bash

# disable 1nic auto configuration
/usr/bin/setdb provision.1nicautoconfig disable

# wait for mcpd ready before attempting any tmsh command(s)
source /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

# create user
tmsh create auth user ${admin_username} password ${admin_password} shell tmsh partition-access replace-all-with { all-partitions { role admin } }

# save config
tmsh save sys config

/bin/curl -L -o /tmp/f5-appsvcs-templates-1.1.0-1.noarch.rpm https://github.com/f5networks/f5-appsvcs-templates/releases/download/v1.1.0/f5-appsvcs-templates-1.1.0-1.noarch.rpm

mkdir -p /var/lib/cloud/icontrollx_installs
cp /tmp/f5-appsvcs-templates-1.1.0-1.noarch.rpm /var/lib/cloud/icontrollx_installs/f5-appsvcs-templates-1.1.0-1.noarch.rpm

mkdir /config/cloud

cat << 'EOF' > /config/cloud/onboard_config.yaml
---
runtime_parameters:
  - name: ADMIN_PASS
    type: secret
    secretProvider:
      environment: aws
      type: SecretsManager
      secretId: ${secret_id}
      version: AWSCURRENT
  - name: HOST_NAME
    type: metadata
    metadataProvider:
      environment: aws
      type: compute
      field: hostname
  - name: SELF_IP_EXTERNAL
    type: metadata
    metadataProvider:
      environment: aws
      type: network
      field: local-ipv4s
      index: 1
  - name: DEFAULT_ROUTE
    type: metadata
    metadataProvider:
      environment: aws
      type: network
      field: subnet-ipv4-cidr-block
      index: 1
  - name: MGMT_ROUTE
    type: metadata
    metadataProvider:
      environment: aws
      type: network
      field: subnet-ipv4-cidr-block
      index: 0
pre_onboard_enabled:
  - name: example_inline_command
    type: inline
    commands:
      - touch /tmp/pre_onboard_script.sh
      - chmod 777 /tmp/pre_onboard_script.sh
      - echo "touch /tmp/created_by_autogenerated_pre_local" > /tmp/pre_onboard_script.sh
  - name: example_local_exec
    type: file
    commands:
      - /tmp/pre_onboard_script.sh
  - name: example_remote_exec
    type: url
    commands:
      - https://cdn.f5.com/product/cloudsolutions/templates/f5-aws-cloudformation/examples/scripts/remote_pre_onboard.sh
post_onboard_enabled:
  - name: example_inline_command
    type: inline
    commands:
      - touch /tmp/post_onboard_script.sh
      - chmod 777 /tmp/post_onboard_script.sh
      - echo "touch /tmp/created_by_autogenerated_post_local" > /tmp/post_onboard_script.sh
  - name: example_local_exec
    type: file
    commands:
      - /tmp/post_onboard_script.sh
  - name: example_remote_exec
    type: url
    commands:
      - https://cdn.f5.com/product/cloudsolutions/templates/f5-aws-cloudformation/examples/scripts/remote_post_onboard.sh
extension_packages:
  install_operations:
    - extensionType: do
      extensionVersion: 1.14.0
    - extensionType: as3
      extensionVersion: 3.20.0
      extensionUrl: https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.20.0/f5-appsvcs-3.20.0-3.noarch.rpm
      extensionHash: ba2db6e1c57d2ce6f0ca20876c820555ffc38dd0a714952b4266c4daf959d987
    - extensionType: ilx
      extensionUrl: https://github.com/f5networks/f5-appsvcs-templates/releases/download/v1.1.0/f5-appsvcs-templates-1.1.0-1.noarch.rpm
      extensionVerificationEndpoint: /mgmt/shared/fast/info
extension_services:
  service_operations:
    - extensionType: do
      type: url
      value: https://cdn.f5.com/product/cloudsolutions/templates/f5-aws-cloudformation/examples/modules/failover_bigip/do.json
    - extensionType: as3
      type: url
      value: https://cdn.f5.com/product/cloudsolutions/templates/f5-azure-arm-templates/examples/modules/bigip/autoscale_as3.json

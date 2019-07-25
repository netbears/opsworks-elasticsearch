# frozen_string_literal: true

default['elasticsearch']['version']                             = '7.2.0'
default['elasticsearch']['main_version']                        = '7.x'
default['elasticsearch']['conf_path']                           = '/etc/elasticsearch'
default['elasticsearch']['data_path']                           = '/elasticsearch'
default['elasticsearch']['log_path']                            = '/var/log/elasticsearch'
default['elasticsearch']['lib_path']                            = '/var/lib/elasticsearch'
default['elasticsearch']['cluster_name']                        = 'es'
default['elasticsearch']['http_port']                           = '9200'
default['elasticsearch']['region']                              = 'eu-west-1'
default['elasticsearch']['discovery_ec2_endpoint']              = "ec2.#{node['elasticsearch']['region']}.amazonaws.com"
default['elasticsearch']['seed_providers']                      = 'ec2'
default['elasticsearch']['discovery_ec2_groups']                = 'MANDATORY'
default['elasticsearch']['discovery_ec2_host_type']             = 'private_ip'
default['elasticsearch']['bucket_snapshot_name']                = 'funktionslust-opsworks-elasticsearch-backup'
default['elasticsearch']['initial_heap_size']                   = JvmOptions::Helper.jvm_initial_heap_size 								# in GB
default['elasticsearch']['maximum_heap_size']                   = JvmOptions::Helper.jvm_maximum_heap_size 								# in GB

default['elasticsearch']['cluster_initial_master_nodes']        = 'Empty'

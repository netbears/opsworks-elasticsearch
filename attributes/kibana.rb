# frozen_string_literal: true

default['kibana']['version']                             = '7.2.0'
default['kibana']['conf_path']                           = '/etc/kibana'
default['kibana']['server_port']                         = '5601'
default['kibana']['server_defaultRoute']                 = '/app/kibana'
default['kibana']['kibana_index']                        = '.index'
default['kibana']['kibana_defaultAppId']                 = 'home'
default['kibana']['path_data']                           = '/kibana'
default['kibana']['status_allowAnonymous']               = 'true'

# frozen_string_literal: true

default['filebeat']['version']           = '7.4.2'
default['filebeat']['conf_path']         = '/etc/filebeat'
default['filebeat']['bulk_max_size']     = '2048'
default['filebeat']['number_of_shards']  = '1'
default['filebeat']['logs']['external']  = 'false'
default['filebeat']['logs']['hostname']  = ''

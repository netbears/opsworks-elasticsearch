# frozen_string_literal: true

package 'kibana' do
  version node['kibana']['version']
end

instance           = search('aws_opsworks_instance', 'self:true').first
kibana_server_host = instance['private_ip']
kibana_es_url      = "http://#{kibana_server_host}:9200"

template "#{node['kibana']['conf_path']}/kibana.yml" do
  source 'kibana.yml.erb'
  owner 'root'
  group 'kibana'
  mode  '0660'
  variables kibana_server_host: kibana_server_host,
            kibana_es_url: kibana_es_url
  action :create
end

directory "#{node['kibana']['path_data']}/" do
  owner 'kibana'
  group 'kibana'
  recursive true
end

service 'kibana' do
  action %i[enable restart]
end

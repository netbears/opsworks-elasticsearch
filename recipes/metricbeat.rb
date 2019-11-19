# frozen_string_literal: true

instance = search('aws_opsworks_instance', 'self:true').first
hostname = instance['private_ip']

directory "#{node['metricbeat']['conf_path']}/" do
  owner 'root'
  group 'root'
  recursive true
end

template "#{node['metricbeat']['conf_path']}/metricbeat.yml" do
  source 'metricbeat.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

remote_file '/tmp/metricbeat.deb' do
  source "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-#{node['metricbeat']['version']}-amd64.deb"
  owner 'root'
  group 'root'
  mode '0755'
  backup false
end

execute 'extract_metricbeat' do
  command <<-BASH
    printf 'N\n' | dpkg -i /tmp/metricbeat.deb
    metricbeat modules enable elasticsearch
    metricbeat modules enable kibana
    metricbeat setup || true
  BASH
end

template "#{node['metricbeat']['conf_path']}/modules.d/elasticsearch.yml" do
  source 'metricbeat-module-elasticsearch.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

template "#{node['metricbeat']['conf_path']}/modules.d/kibana.yml" do
  source 'metricbeat-module-kibana.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

service 'metricbeat' do
  action %i[enable restart]
end

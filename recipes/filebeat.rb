# frozen_string_literal: true

instance = search('aws_opsworks_instance', 'self:true').first
hostname = instance['private_ip']

hostname = node['filebeat']['logs']['hostname'] if node['filebeat']['logs']['external'] == 'true'

directory "#{node['filebeat']['conf_path']}/" do
  owner 'root'
  group 'root'
  recursive true
end

template "#{node['filebeat']['conf_path']}/filebeat.yml" do
  source 'filebeat.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

remote_file '/tmp/filebeat.deb' do
  source "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-#{node['filebeat']['version']}-amd64.deb"
  owner 'root'
  group 'root'
  mode '0755'
  backup false
end

execute 'extract_filebeat' do
  command <<-BASH
    printf 'N\n' | dpkg -i /tmp/filebeat.deb
    filebeat modules enable elasticsearch
  BASH
end

template "#{node['filebeat']['conf_path']}/modules.d/elasticsearch.yml" do
  source 'filebeat-module-elasticsearch.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

execute 'setup_filebeat' do
  command <<-BASH
    filebeat setup || true
  BASH
end

service 'filebeat' do
  action %i[enable restart]
end

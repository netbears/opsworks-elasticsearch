# frozen_string_literal: true

instance = search('aws_opsworks_instance', 'self:true').first
hostname = instance['private_ip']

directory "#{node['heartbeat']['conf_path']}/" do
  owner 'root'
  group 'root'
  recursive true
end

template "#{node['heartbeat']['conf_path']}/heartbeat.yml" do
  source 'heartbeat.yml.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables private_ip: hostname
  action :create
end

remote_file '/tmp/heartbeat.deb' do
  source "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-#{node['heartbeat']['version']}-amd64.deb"
  owner 'root'
  group 'root'
  mode '0755'
  backup false
end

execute 'extract_heartbeat' do
  command <<-BASH
    printf 'N\n' | dpkg -i /tmp/heartbeat.deb
    heartbeat setup
  BASH
end

service 'heartbeat-elastic' do
  action %i[enable restart]
end

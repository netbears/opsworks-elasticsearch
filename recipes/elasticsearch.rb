# frozen_string_literal: true

package 'elasticsearch' do
  version node['elasticsearch']['version']
end

instance = search('aws_opsworks_instance', 'self:true').first
hostname = instance['private_ip']

template "#{node['elasticsearch']['conf_path']}/elasticsearch.yml" do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode  '0660'
  variables private_ip: hostname,
            initial_node: node['elasticsearch']['cluster_initial_master_nodes']
  action :create
end

template "#{node['elasticsearch']['conf_path']}/elasticsearch.snapshot.sh" do
  source 'elasticsearch.snapshot.sh.erb'
  owner 'root'
  group 'elasticsearch'
  mode  '0775'
  variables private_ip: hostname
  action :create
end

cron 'elasticsearch_snapshot' do
  minute '00'
  hour '00'
  day '*'
  month '*'
  weekday '*'
  user 'root'
  command "#{node['elasticsearch']['conf_path']}/elasticsearch.snapshot.sh"
end

template "#{node['elasticsearch']['conf_path']}/jvm.options" do
  source 'jvm.options.erb'
  owner 'root'
  group 'elasticsearch'
  mode  '0660'
  action :create
end

directory "#{node['elasticsearch']['log_path']}/" do
  owner 'elasticsearch'
  group 'elasticsearch'
  recursive true
end

directory "#{node['elasticsearch']['data_path']}/" do
  owner 'elasticsearch'
  group 'elasticsearch'
  recursive true
end

execute "(printf 'y' | /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2) || true"

execute "(printf 'y' | /usr/share/elasticsearch/bin/elasticsearch-plugin install repository-s3) || true"

template '/mount-ssd.sh' do
  source 'mount-ssd.sh.erb'
  owner 'root'
  group 'root'
  mode  '0775'
  action :create
end

execute '/mount-ssd.sh'

template '/etc/security/limits.conf' do
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  action :create
end

template '/usr/lib/systemd/system/elasticsearch.service' do
  source 'elasticsearch.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

execute 'systemctl daemon-reload'

execute 'service elasticsearch restart'

# frozen_string_literal: true

instance = search('aws_opsworks_instance', 'self:true').first
private_ip = instance['private_ip']
hostname = instance['hostname']

remote_file '/tmp/elasticsearch_exporter.tar.gz' do
  source "https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v#{node['elasticsearch_exporter']['version']}/elasticsearch_exporter-#{node['elasticsearch_exporter']['version']}.linux-amd64.tar.gz"
  owner 'root'
  group 'root'
  mode '0755'
  backup false
  action :create_if_missing
  notifies :run, 'execute[extract_elasticsearch_exporter]', :immediately
end

execute 'extract_elasticsearch_exporter' do
  command <<-BASH
    tar xf /tmp/elasticsearch_exporter.tar.gz
    mv elasticsearch_exporter-#{node['elasticsearch_exporter']['version']}.linux-amd64/elasticsearch_exporter /usr/local/bin/elasticsearch_exporter
    chmod +x /usr/local/bin/elasticsearch_exporter
  BASH
  action :nothing
end

poise_service 'elasticsearch_exporter' do
  user 'root'
  command <<-BASH
    /usr/local/bin/elasticsearch_exporter \
      --web.listen-address=":9114" \
      --web.telemetry-path="/metrics" \
      --es.uri="http://#{private_ip}:9200" \
      --es.indices \
      --es.timeout 20s \
      --es.node="#{hostname}" \
      --es.indices_settings \
      --es.cluster_settings  \
      --es.shards \
      --es.snapshots

  BASH
  action %i[enable restart]
end

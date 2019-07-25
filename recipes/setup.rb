# frozen_string_literal: true

execute 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -'

file "/etc/apt/sources.list.d/elastic-#{node['elasticsearch']['main_version']}.list" do
  content "deb https://artifacts.elastic.co/packages/#{node['elasticsearch']['main_version']}/apt stable main"
end

execute 'apt-get update'

(node['base_packages'] + node['custom_packages']).each do |pkg|
  package pkg
end

include_recipe 'elasticsearch_stack::swap_sysctl'

include_recipe 'elasticsearch_stack::logrotate'

include_recipe 'elasticsearch_stack::ulimit'

include_recipe 'elasticsearch_stack::elasticsearch'

include_recipe 'elasticsearch_stack::kibana'

include_recipe 'elasticsearch_stack::node_exporter'

execute 'sleep_before_plugins' do
  command <<-BASH
    sleep 120
  BASH
end

include_recipe 'elasticsearch_stack::heartbeat'

include_recipe 'elasticsearch_stack::metricbeat'

include_recipe 'elasticsearch_stack::filebeat'

include_recipe 'ntp::default'

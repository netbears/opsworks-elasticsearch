# frozen_string_literal: true

template '/etc/security/limits.d/elasticsearch_limits.conf' do
  source 'elasticsearch_limits.conf.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  action :create
end

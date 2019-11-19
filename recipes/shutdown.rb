# frozen_string_literal: true

execute 'service elasticsearch stop'

include_recipe 'elasticsearch_stack::deregister_targets_nlb' if node['nlb']['register'] == 'true'

execute 'sleep_after_deregister' do
  command <<-BASH
    sleep 60
  BASH
end

service 'filebeat' do
  action %i[stop]
end

service 'metricbeat' do
  action %i[stop]
end

service 'heartbeat-elastic' do
  action %i[stop]
end

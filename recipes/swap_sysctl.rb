# frozen_string_literal: true

bash 'disable-swap-and-set-sysctl' do
  user 'root'
  code <<-BASH
    swapoff -a
    sysctl -w vm.max_map_count=262144
  BASH
end

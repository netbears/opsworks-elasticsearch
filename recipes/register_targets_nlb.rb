# frozen_string_literal: true

instance = search('aws_opsworks_instance', 'self:true').first
ec2_instance_id = instance['ec2_instance_id']

execute 'register_target' do
  command <<-BASH
    aws elbv2 register-targets --region #{node['elasticsearch']['region']} \
      --target-group-arn #{node['nlb']['target_groups']['9200']} \
      --targets Id=#{ec2_instance_id}

    aws elbv2 register-targets --region #{node['elasticsearch']['region']} \
      --target-group-arn #{node['nlb']['target_groups']['9300']} \
      --targets Id=#{ec2_instance_id}

    aws elbv2 register-targets --region #{node['elasticsearch']['region']} \
      --target-group-arn #{node['nlb']['target_groups']['5601']} \
      --targets Id=#{ec2_instance_id}
  BASH
end

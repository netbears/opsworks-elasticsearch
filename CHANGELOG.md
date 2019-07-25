### 1.8.7
* Make file permissions look "normal"

### 1.8.6
* Patch clustername in snapshot script

### 1.8.5
* Patch permissions for metricbeat modules

### 1.8.4
* Patch permissions for filebeat elasticsearch-module

### 1.8.3
* Patch path to debian file for filebeat

### 1.8.2
* Patch default configuration for filebeat

### 1.8.1
* Patch sleep method for clear code

### 1.8.0
* Drop support for cloudwatch and add support for filebeat

### 1.7.0
* Deploy metricbeat and plug it in to elasticsearch and kibana

### 1.6.5
* Redeploy heartbeat-elastic regardless of failure status

### 1.6.4
* Disable value for gateway.recover_after_nodes and patch initial_master logic discovery 

### 1.6.3
* Disable xpack security and rethink discovery ec2 provider logic

### 1.6.2
* Bugfix cloudwatch agent install

### 1.6.1
* Expect at least 1 master node (instead of 2)
* Open ELB port for Kibana

### 1.6.0
* Switch to manually-defined elasticsearch service definition
* Push elasticsearch logs to CloudWatch

### 1.5.1
* Forgot to remove user_ulimit logic

### 1.5.0
* Lose support for ulimit recipe and create limits for elasticsearch from template

### 1.4.2
* Patch filename in elasticsearch recipe

### 1.4.1
* Patch data folder permissions and limits.conf

### 1.4.0
* Publish private ip address instead of loopback for es
* Fix permissions for log path directory
* Further parameterize jvm.options template

### 1.3.6
* Patch jvm.options ram computation
* Patch heartbeat install

### 1.3.5
* Fix es config and make sure heartbeat directory exists

### 1.3.4
* Memlock not needed as limits are applied via ulimit

### 1.3.3
* Downgrade windows library to 3.4.0

### 1.3.2
* Downgrade seven_zip library to 2.0.2

### 1.3.1
* Patch bug related to cluster initial nodes
* Deploy stack in its own VPC

### 1.3.0
* Support tags and snapshot to buckets

### 1.2.0
* Support list of existing master nodes
* Use logrotate

### 1.1.0
* Add some optimizations

### 1.0.0
* Initial release

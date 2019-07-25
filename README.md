# OpsWorks ElasticSearch cookbook

## Notes about the stacks
1) CloudFormation:
- it's an infrastructure-as-code stack deployment script written by AWS that creates resources based on the definition within the file
- The format is simple: YAML fille with at least a `Resources` key in which you define your resources
- More information here: https://aws.amazon.com/cloudformation/

2) OpsWorks:
- it's a "control-plane" that provisions Chef-based resources using custom cookbooks
- the "master" instance is self-managed and FREE, as provided by AWS
- the stacks can contain `Layers`, which encompass `Instances` that are bootstrapped using a custom cookbook created by the user
- More info here: https://aws.amazon.com/opsworks/

3) Chef and Ruby:
- this entire stack is written in Ruby in order to be provisioned using Chef (through AWS OpsWorks)
- Chef suggests using the following set of folders:
* `attributes` - to define parameters with default values
* `libraries` - to define any libraries to be used within the code
* `recipes` - to define what resources to be provisioned
* `templates` - to define files that will be generated within the stack

## SSH permissions

SSH is handled by OpsWorks automatically. In order to grant a user SSH permissions, the following needs to happen:
1) The user needs to have an SSH public key set up

To do that, have the user go here to the `Users` menu in OpsWorks, click on his IAM user, then on `Edit`, paste the public key and then hit `Save`.

Or you can do that for him. Whatever makes more sense for you.

2) Assign `SUDO` and/or `SSH` permissions in the `Permissions` tab for the stack that you want to give him permissions for.

Click on `Edit`, tick the boxes for `sudo` and/or `ssh` and hit `Save`

3) The OpsWorks agent should automatically run the default recipe on all instances and give access to the user within 5 minutes.

If that doesn't happen or you want to speed things up, just go to the `Deployments` tab, hit `Run Command` and execute the `Configure` command on all running instances.

## Add new nodes to cluster

* Go to your stack
* Click on `Instances`
* Click on `+ Instance`
* Make sure you  select the following values:
```
Size = something in the i3.* family (just not `i3.*metal). preferably `i3.large, i3.xlarge or i3.2xlarge`
Volume size (under Advanced) = 50
```
* Click on `start` for that specific instance

`Important`: It is a good idea to use `i3.*` instances as this is why they were built for -> https://aws.amazon.com/ec2/instance-types/i3/

## Upgrade the ElasticSearch version to something newer (default is 7.2.0)

### Prepare your cluster

* SSH to any running instance
```bash
export ES_HOST=<ipv4_private_ip_here_of_the_instance_you_are_on>:9200
```

* Disable shard allocation
```bash
curl -X PUT "$ES_HOST/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}
'
```
* Stop non-essential indexing and perform a synced flush
```bash
curl -X POST "$ES_HOST/_flush/synced"
```

### Stop elasticsearch service in each node
* SSH to every node and run
```bash
service elasticsearch stop
```

### Update the OpsWorks stack CustomJson

* Go to your OpsWorks stack and ADD the following CustomJSON properties (do NOT remove any existing properties):
```bash
{
  "elasticsearch": {
    "version": "7.4.0".   (or whatever is the new version)
  }
}
```

The resulting JSON should look something like this:
```bash
{
    "elasticsearch": {
        "version": "7.4.0",
        "region": "eu-west-1",
        "cluster_name": "es",
        "discovery_ec2_groups": "some-security-group-id",
        "bucket_snapshot_name": "netbears-elasticsearch-backup-staging"
    },
    "cloudwatch": {
        "region": "eu-west-1"
    }
}
```
* Go to `Deployments` section, select `Execute Recipes` and execute the following recipe on all running instances:
```bash
elasticsearch_stack::elasticsearch
```

### Bring your cluster back up

* SSH to any running instance
```bash
export ES_HOST=<ipv4_private_ip_here_of_the_instance_you_are_on>:9200
```

* Enable short allocation
```bash
curl -X PUT "$ES_HOST/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
'
```


## Deploying new changes

The `master` recipe is `libraries/setup.rb` and contains the flow to launch all other resouces in order.

### Create new recipe

* Create a new file within `libraries` folder and call it `my_new_recipe.rb` 
* Define the resources that you need created within it
* Include that file within `libraries/setup.rb` with format `include_recipe 'elasticsearch_stack::my_new_recipe'`
* Update the revision reference within `metadata.rb`, `Berksfile.lock` and include a definition within `CHANGELOG.md`
* Git commit, push and tag your revision
* Run the `berks package` command and upload it to an HTTP location
* Update the correct CloudFormation stack

### Deploy new recipe to stack
* After you updated the CloudFormation stack, go to your OpsWorks stack definition
* Click on `Deployments`
* Run first the `Update custom cookbooks` command on all running instances (takes around 30 seconds)
* Run then the `Setup` command on the same instances

## Monitoring

The stack automatically deploys the following logic:
- NodeExporter: which can be connected to any running Prometheus instance
- CloudWatch: because underlying system is OpsWorks for provisioning, you get the benefits of exporting automatically granular data to CloudWatch which can be viewed in the Monitoring section of the stack
- Heapster: this is available through the Kibana UI and offers relevant information about all running nodes of the cluster
- Metricbeat: this is available through the Kibana UI and offers more detailed information about the running nodes in the cluster than Heapster (complementary data)

## Logging

The stack pushes all ElasticSearch logs within to fluentd and then they are stored in the same ElasticSearch stack under index `filebeat-*`.

## Initial deploy method

* Go to CloudFormation and launch the stack. The default parameters work just fine, but you might want to tweak them for all intents and purposes
* Initially, 3 nodes will be deployed in the newly created private subnets


## Notes
* JVM memory is being computed automatically based on instance type and is set at 60% of available RAM
* Node discovery is being done automatically using EC2 method
* Snapshot is done automatically ad midnight on each node and pushed to S3

## Backup ElasticSearch

ElasticSearch backup is done automatically via cronjob, for each instance, nighly.

Full details about all the commands are here -> https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html

You can use the below ones to view/restore a snapshot for a cluster.

### View snapshots for an ES cluster

```
export ES_HOST=<ipv4_private_ip_here_of_the_instance_you_are_on>:9200
export cluster="YOUR_CLUSTER_NAME_HERE"
curl -X GET "${ES_HOST}s/_snapshot/${cluster}/_all"
```

### Restore snapshots for an ES cluster

```
cluster="YOUR_CLUSTER_NAME_HERE"
snapshot="SNAPSHOT_ID_FROM_ABOVE_COMMAND_HERE"
curl -X POST "${ES_HOST}/_snapshot/my_backup/${snapshot}/_restore"
```


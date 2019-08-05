ifeq (,$(wildcard .env))
$(error "Please create the .env file first. Use .env.dist as baseline.")
endif

ifeq (, $(shell which aws))
$(error "AWS CLI was not detected in $(PATH). Please install it first.")
endif

include .env

FETCH_PARAMETERS = $(shell cat parameters.json)
SET_PARAMETERS = $(eval export PARAMETERS=$(FETCH_PARAMETERS))

FETCH_STACKID = $(shell aws cloudformation describe-stacks --profile ${AwsProfile} --stack-name ${StackName} --query "Stacks[0].Outputs[?OutputKey=='OpsWorksStackId'].OutputValue" --output text)
SET_STACK_ID = $(eval export STACK_ID=$(FETCH_STACKID))

launch_stack:
	$(SET_PARAMETERS)
	aws cloudformation create-stack \
		--stack-name ${StackName} \
		--template-body file://cloudformation-template.yaml \
		--profile ${AwsProfile} \
		--capabilities CAPABILITY_IAM  CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters '${PARAMETERS}'
	aws cloudformation wait stack-create-complete --stack-name ${StackName} --profile ${AwsProfile}
update_stack:
	$(SET_PARAMETERS)
	aws cloudformation update-stack \
		--stack-name ${StackName} \
		--template-body file://cloudformation-template.yaml \
		--profile ${AwsProfile} \
		--capabilities CAPABILITY_IAM  CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters '${PARAMETERS}'
	aws cloudformation wait stack-update-complete --stack-name ${StackName} --profile ${AwsProfile}
	make setup
delete_stack:
	aws cloudformation delete-stack \
		--stack-name ${StackName} \
		--profile ${AwsProfile}
setup:
	$(SET_STACK_ID)
	DEPLOYMENT=`aws --profile $(AwsProfile) opsworks create-deployment --stack-id ${STACK_ID} --command Name=update_custom_cookbooks --output text`; \
	echo $$DEPLOYMENT; \
	aws --profile $(AwsProfile) opsworks wait deployment-successful --deployment-ids $$DEPLOYMENT
	DEPLOYMENT=`aws --profile $(AwsProfile) opsworks create-deployment --stack-id ${STACK_ID} --command Name=setup --output text`; \
	echo $$DEPLOYMENT; \
	aws --profile $(AwsProfile) opsworks wait deployment-successful --deployment-ids $$DEPLOYMENT

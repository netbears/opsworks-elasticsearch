ifeq (,$(wildcard .env))
$(error "Please create the .env file first. Use .env.dist as baseline.")
endif

ifeq (, $(shell which aws))
$(error "AWS CLI was not detected in $(PATH). Please install it first.")
endif

include .env

FETCH_PARAMETERS = $(shell cat parameters.json)
SET_PARAMETERS = $(eval export PARAMETERS=$(FETCH_PARAMETERS))

update_stack:
	$(SET_PARAMETERS)
	aws cloudformation update-stack \
		--stack-name ${StackName} \
		--template-body file://cloudformation-template.yaml \
		--profile ${AwsProfile} \
		--capabilities CAPABILITY_IAM  CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters '${PARAMETERS}'
	aws cloudformation wait stack-update-complete --stack-name ${StackName} --profile ${AwsProfile}
launch_stack:
	$(SET_PARAMETERS)
	aws cloudformation create-stack \
		--stack-name ${StackName} \
		--template-body file://cloudformation-template.yaml \
		--profile ${AwsProfile} \
		--capabilities CAPABILITY_IAM  CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters '${PARAMETERS}'
	aws cloudformation wait stack-create-complete --stack-name ${StackName} --profile ${AwsProfile}
delete_stack:
	aws cloudformation delete-stack \
		--stack-name ${StackName} \
		--profile ${AwsProfile}

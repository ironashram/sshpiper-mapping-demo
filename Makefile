.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

wait:
	sleep 20

.PHONY: destroy
destroy: ## Delete environment
	@echo "--> Destroying components"
	@docker-compose down

.PHONY: enter
enter: ## Enter to SSHPiper container
	@echo "--> Entering SSHPiper container"
	@docker exec -it $$(docker ps | grep sshpiper-mapping-demo_sshpiperd_1 | awk '{print $$1}') sh

.PHONY: enter-mysql
enter-mysql: ## Enter to SSHPiper database
	@echo "--> Entering SSHPiper database"
	@docker exec -it $$(docker ps | grep sshpiper-mapping-demo_sshpiper-database_1 | awk '{print $$1}') mysql -u root -psshpiper

.PHONY: logs
logs: ## Output logs from SSHPiper container
	@docker logs -f sshpiper-mapping-demo_sshpiperd_1

.PHONY: createEnv
createEnv: ## Start environment
	@echo "--> Starting components"
	@docker-compose up -d

.PHONY: createPipe
createPipe: ## Create pipe and populate mysql
	@echo "--> Populating mysql"
	@docker exec -it $$(docker ps | grep sshpiper-mapping-demo_sshpiperd_1 | awk '{print $$1}') sh -c '/usr/local/bin/sshpiperd --config $$SSHPIPERD_CONFIG pipe add -n one_user -u 172.29.2.4 -p 2222 --upstream-username different_user'
	@docker cp test/sql/populate_mysql.sql $$(docker ps | grep sshpiper-mapping-demo_sshpiper-database_1 | awk '{print $$1}'):/home
	@docker exec -it $$(docker ps | grep sshpiper-mapping-demo_sshpiper-database_1 | awk '{print $$1}') sh -c 'mysql -u root -psshpiper < /home/populate_mysql.sql'
	@echo "Now to to 'ssh -o UserKnownHostsFile=/dev/null one_user@127.0.0.1 -p2233 with password 'onepass'"
	@echo "This will map one_user with password authentication to SSHPiper to different_user key based authentication on the other container"

start: createEnv wait createPipe

%:
  @:

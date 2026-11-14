# Pass extra flags with ARGS, for example: make run ARGS=-K (asks for the sudo password).
PLAYBOOK := ansible-playbook

.PHONY: deps inventory lint check dry-run run idempotence verify

deps: ## Install the collections (only needed with ansible-core)
	ansible-galaxy collection install -r requirements.yml

inventory: ## Make your local inventory from the example
	test -f inventory/hosts.yml || cp inventory/hosts.example.yml inventory/hosts.yml

lint: ## Lint and syntax check; no server needed
	ansible-lint
	$(PLAYBOOK) -i inventory/hosts.example.yml site.yml verify.yml --syntax-check

check: lint ## What CI runs

dry-run: ## Show what would change, change nothing
	$(PLAYBOOK) site.yml --check --diff $(ARGS)

run: ## Apply the playbook for real
	$(PLAYBOOK) site.yml --diff $(ARGS)

idempotence: ## Run again; fail unless nothing changed
	$(PLAYBOOK) site.yml $(ARGS) | tee evidence/second-run.txt
	grep -qE 'changed=0 +unreachable=0 +failed=0' evidence/second-run.txt

verify: ## Check the real result on the server
	$(PLAYBOOK) verify.yml $(ARGS)

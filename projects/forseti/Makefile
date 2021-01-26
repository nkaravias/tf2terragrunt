# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Make will use bash instead of sh
#SHELL := /usr/bin/env zsh
#source ~/oh-my-zsh.sh
#source ~/.zshrc
TF_VAR := dev-bopper
POLICY_REPO=policy-library

plan:
	@echo "Running tf plan and generating json output in plans/"
	terraform plan --var-file=$(TF_VAR).tfvars --out=plans/$(TF_VAR).tfplan && \
  terraform show -json plans/$(TF_VAR).tfplan > plans/$(TF_VAR).json


validate:
	@echo "Running tf plan and generating json output in plans/"
	tf-validator validate plans/$(TF_VAR).json --policy-path $(POLICY_REPO)


test: ## Test constraint templates via OPA
	@echo "Running OPA tests..."
	@opa test --timeout 30s -v lib/ validator/ --explain=notes

docker_test_opa_v15: ## Run tests using CV rego docker image v0.15.x
	docker run -it --rm \
		-v "$(CURDIR):/workspace" \
		-w=/workspace \
		$(CV_IMAGE_URL)/$(REGO_IMAGE_V15):$(REGO_IMAGE_TAG) \
		test

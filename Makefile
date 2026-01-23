.PHONY: help swmm-build swmm-push swmm-test \
        epanet-build epanet-push epanet-test

# ============================================================================
# COLORS FOR OUTPUT
# ============================================================================

BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# ============================================================================
# DEFAULT TARGET
# ============================================================================

help:
	@echo "$(BLUE)Water Resources Modeling - Docker Engines$(NC)"
	@echo ""
	@echo "$(GREEN)SWMM (Stormwater Management Model):$(NC)"
	@echo "  make swmm-build     - Build all SWMM versions locally"
	@echo "  make swmm-push      - Build and push SWMM to Docker Hub (multi-arch)"
	@echo "  make swmm-test      - Test all built SWMM versions"
	@echo ""
	@echo "$(GREEN)EPANET (Water Network Analysis):$(NC)"
	@echo "  make epanet-build   - Build all EPANET versions locally"
	@echo "  make epanet-push    - Build and push EPANET to Docker Hub (multi-arch)"
	@echo "  make epanet-test    - Test all built EPANET versions"
	@echo ""

# ============================================================================
# SWMM TARGETS
# ============================================================================

swmm-build:
	@echo "$(BLUE)Building all SWMM versions...$(NC)"
	cd engine/SWMM/scripts && ./build-all-tags.sh
	@echo "$(GREEN)✓ SWMM build complete!$(NC)"

swmm-push:
	@echo "$(BLUE)Pushing all SWMM versions to Docker Hub...$(NC)"
	cd engine/SWMM/scripts && ./push-all-tags.sh
	@echo "$(GREEN)✓ SWMM push complete!$(NC)"

swmm-test:
	@echo "$(BLUE)Testing all SWMM versions...$(NC)"
	cd engine/SWMM/scripts && ./test-all-tags.sh
	@echo "$(GREEN)✓ SWMM test complete!$(NC)"

# ============================================================================
# EPANET TARGETS
# ============================================================================

epanet-build:
	@echo "$(BLUE)Building all EPANET versions...$(NC)"
	cd engine/EPANET/scripts && ./build-all-tags.sh
	@echo "$(GREEN)✓ EPANET build complete!$(NC)"

epanet-push:
	@echo "$(BLUE)Pushing all EPANET versions to Docker Hub...$(NC)"
	cd engine/EPANET/scripts && ./push-all-tags.sh
	@echo "$(GREEN)✓ EPANET push complete!$(NC)"

epanet-test:
	@echo "$(BLUE)Testing all EPANET versions...$(NC)"
	cd engine/EPANET/scripts && ./test-all-tags.sh
	@echo "$(GREEN)✓ EPANET test complete!$(NC)"

# ============================================================================
# OLD TARGETS (DEPRECATED - Kept for reference)
# ============================================================================

docker-run-swmm:
ifndef INPUT
	$(error INPUT is required. Usage: make docker-run-swmm INPUT=example.inp)
endif
	@echo "$(BLUE)Running SWMM in Docker...$(NC)"
	docker run --rm -v $$(pwd):/data neeraip/wrm:swmm-5.2.4 /data/$(INPUT)
	@echo "$(GREEN)✓ SWMM simulation complete!$(NC)"

docker-run-epanet:
ifndef INPUT
	$(error INPUT is required. Usage: make docker-run-epanet INPUT=example.inp)
endif
	@echo "$(BLUE)Running EPANET in Docker...$(NC)"
	docker run --rm -v $$(pwd):/data neeraip/wrm:epanet-2.3.3 /data/$(INPUT)
	@echo "$(GREEN)✓ EPANET simulation complete!$(NC)"

docker-run-swmm-db:
ifndef SIMULATION_ID
	$(error SIMULATION_ID is required. Usage: make docker-run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef DATABASE_URL
	$(error DATABASE_URL is required. Usage: make docker-run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef INPUT
	$(error INPUT is required. Usage: make docker-run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
	@echo "$(BLUE)Running SWMM in Docker with database tracking...$(NC)"
	docker run --rm -v $$(pwd):/data \
		-e SIMULATION_ID=$(SIMULATION_ID) \
		-e DATABASE_URL=$(DATABASE_URL) \
		neeraip/wrm:swmm-5.2.4 /data/$(INPUT)
	@echo "$(GREEN)✓ SWMM simulation complete!$(NC)"

docker-run-epanet-db:
ifndef SIMULATION_ID
	$(error SIMULATION_ID is required. Usage: make docker-run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef DATABASE_URL
	$(error DATABASE_URL is required. Usage: make docker-run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef INPUT
	$(error INPUT is required. Usage: make docker-run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
	@echo "$(BLUE)Running EPANET in Docker with database tracking...$(NC)"
	docker run --rm -v $$(pwd):/data \
		-e SIMULATION_ID=$(SIMULATION_ID) \
		-e DATABASE_URL=$(DATABASE_URL) \
		neeraip/wrm:epanet-2.3.3 /data/$(INPUT)
	@echo "$(GREEN)✓ EPANET simulation complete!$(NC)"

# ============================================================================
# NATIVE EXECUTION
# ============================================================================

run-swmm:
ifndef INPUT
	$(error INPUT is required. Usage: make run-swmm INPUT=example.inp)
endif
	@echo "$(BLUE)Running SWMM...$(NC)"
	./cmd/run-swmm.sh $(INPUT)

run-epanet:
ifndef INPUT
	$(error INPUT is required. Usage: make run-epanet INPUT=example.inp)
endif
	@echo "$(BLUE)Running EPANET...$(NC)"
	./cmd/run-epanet.sh $(INPUT)

# ============================================================================
# DATABASE TRACKING
# ============================================================================

run-swmm-db:
ifndef SIMULATION_ID
	$(error SIMULATION_ID is required. Usage: make run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef DATABASE_URL
	$(error DATABASE_URL is required. Usage: make run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef INPUT
	$(error INPUT is required. Usage: make run-swmm-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
	@echo "$(BLUE)Running SWMM with database tracking...$(NC)"
	SIMULATION_ID=$(SIMULATION_ID) DATABASE_URL=$(DATABASE_URL) ./cmd/run-swmm.sh $(INPUT)

run-epanet-db:
ifndef SIMULATION_ID
	$(error SIMULATION_ID is required. Usage: make run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef DATABASE_URL
	$(error DATABASE_URL is required. Usage: make run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
ifndef INPUT
	$(error INPUT is required. Usage: make run-epanet-db SIMULATION_ID=<uuid> DATABASE_URL=postgresql://... INPUT=example.inp)
endif
	@echo "$(BLUE)Running EPANET with database tracking...$(NC)"
	SIMULATION_ID=$(SIMULATION_ID) DATABASE_URL=$(DATABASE_URL) ./cmd/run-epanet.sh $(INPUT)

# ============================================================================
# TESTING
# ============================================================================

test: chmod
	@echo "$(BLUE)Running all tests...$(NC)"
	bash tests/run_all_tests.sh

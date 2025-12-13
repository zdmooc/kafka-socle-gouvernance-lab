.PHONY: deploy smoke report

deploy:
	bash scripts/deploy-all.sh

smoke:
	bash scripts/smoke.sh

report:
	bash scripts/report-weekly.sh kafka report-weekly.md

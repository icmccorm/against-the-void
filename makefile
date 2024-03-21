build: irr
	@Rscript ./scripts/surveys/compile.r
clean-sample:
	@rm -f ./output.csv
	@rm -f ./output.md
	@rm -f ./choices.txt
sample:
	@rm -f ./output.csv
	@rm -f ./output.md
	@python3 ./scripts/sampling/choose.py ./data/interviews/transcripts ./samples/log.txt 80 | tee choices.txt
	@python3 ./scripts/sampling/print.py ./choices.txt ./data/interviews/transcripts
	@rm choices.txt
test_sample:
	python3 ./scripts/sampling/tests.py
clean-irr:
	@rm -rf ./build/irr/
irr: clean-irr
	@Rscript ./scripts/irr/irr.r
clean-build:
	@rm -rf ./build
clean: clean-sample clean-irr clean-build
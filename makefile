compile:
	@sh scripts/compile.sh compile

json:
	@sh scripts/compile.sh json

test:
	@bash tests/run.sh $(TEST)

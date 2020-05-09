.PHONY: all bench build check clean configure exec fast golden haddock hlint main output repl report run stan stylish test tix update

all: update fast bench

bench:
	rm -f helms-benchmark.tix
	cabal new-bench --jobs -f ghcoptions

build:
	cabal new-build --jobs --enable-profiling -f ghcoptions

check:
	cabal check

clean:
	cabal new-clean
	if test -d .cabal-sandbox; then cabal sandbox delete; fi
	if test -d .hpc; then rm -r .hpc; fi
	if test -d .hie; then rm -r .hie; fi

configure:
	rm -f cabal.project.local*
	cabal configure --enable-benchmarks --enable-coverage --enable-tests -f ghcoptions

exec:
	make tix
	cabal new-exec --jobs helms

fast: main report

golden:
	if test -d .output/golden; then rm -r .output/golden; fi

haddock:
	cabal new-haddock

hlint:
	./hlint.sh

main:
	make stylish configure check build test

output:
	if test -d .output; then rm -r .output; fi

repl:
	cabal new-repl lib:helms

report:
	make haddock stan hlint

run:
	make tix
	cabal new-run --jobs helms

stan:
	./stan.sh

stylish:
	stylish-haskell -r -v -i hs

test:
	cabal new-test --jobs --test-show-details=streaming -f ghcoptions

tix:
	rm -f helms.tix

update:
	cabal update

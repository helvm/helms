# 🏗️ INSTALL

How to download, test and run.

## Download

You need a client of `git`:
```bash
git clone https://github.com/helvm/helms.git
cd helms
```

## Compile

To compile you need `cabal` and `make`:
```bash
make
```

## Run

You can run Helps by `cabal` or directly:
```bash
cabal run helms file_to_interpret
```

## By make

```bash
# Update Cabal's list of packages.
cabal update

# Initialize a sandbox and install the package's dependencies.
make install

# Configure & build the package.
make configure
make build

# Test package.
make test

# Benchmark package.
make bench

# Run executable.
# make exec
cabal new-exec helms

# Start REPL.
make repl

# Generate documentation.
make haddock

# Analyze coverage.
make hpc
```

## Other

For more see [CONTRIBUTING](CONTRIBUTING.md).

## 🦄 🌈 ❤️ 💛 💚 💙 🤍 🖤

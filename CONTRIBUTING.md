# Tertestrial Server Developer Documentation

- set up your developer machine:
  - install Node.js
  - `npm i`

- development
  - the source code is in `src`
  - the tests run against the transpiled code in `lib`
  - transpilation happens automatically when running `bin/spec [<filename>]`
  - you can also run `node_modules/.bin/watch` to start a continuously running auto-compiler

- testing
  - run all tests: `bin/spec`
  - run linter: `dependency-lint`
  - run feature specs: `bin/features`

- publish a new version: `publish [patch|minor|major]`

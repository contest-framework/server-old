# Tertestrial Server Developer Documentation

- set up your developer machine:
  - install Node.js
  - `npm i`

- development
  - the source code is in `src`
  - the tests run against the transpiled code in `dist`
  - transpilation happens automatically when running `bin/spec [<filename>]`
  - you can also run `node_modules/.bin/watch` to start a continuously running auto-compiler

- testing
  - run all tests: `bin/spec`
  - run linter: `node_modules/.bin/lint` or `dependency-lint`
  - run feature specs: `bin/features` or `cucumber-js` with auto-compiler running

- publish a new version: `publish [patch|minor|major]`

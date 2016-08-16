# Tertestrial Server Developer Documentation

- set up your developer machine:
  - install Node.js
  - `npm i`

- development
  - the tests run against the transpiled output in `lib`
  - transpilation happens automatically when running `cucumber-js`

- testing
  - run all tests: `bin/spec`
  - run linter: `dependency-lint`
  - run Cucumber: `cucumber-js`

- publish a new version: `publish <[patch|minor|major]>`

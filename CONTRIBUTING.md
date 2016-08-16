# Tertestrial Server Developer Documentation

- set up your developer machine:
  - install Node.js
  - `npm i`

- development
  - the source needs to be transpiled into JavaScript in order for the tests to run
  - this happens automatically when using `bin/spec`
  - if you call `cucumber-js` directly, please have `node_modules/.bin/watch`
    running in the background

- testing
  - run all tests: `bin/spec`
  - run linter: `dependency-lint`
  - run Cucumber: `cucumber-js`

- publish a new version: `publish <[patch|minor|major]>`

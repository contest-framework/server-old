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
  - run linter: `node_modules/.bin/lint` or `node_modules/.bin/dependency-lint`
  - run feature specs: `bin/features` or `node_modules/.bin/cucumber-js` with auto-compiler running

- publish a new version: `node_modules/.bin/publish [patch|minor|major]`
  - deployment of the new version happens on CircleCI

- CI setup
  - [TravisCI](https://travis-ci.org/Originate/tertestrial-server)
    is used for compatibility testing against different Node.JS versions
  - [CircleCI](https://circleci.com/gh/Originate/tertestrial-server)
    is used for development, since it is faster and more reliable

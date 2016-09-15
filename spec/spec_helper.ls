process.env.NODE_ENV = 'test'

require! [chai, sinon]
chai.use require('sinon-chai')

global.chai = chai
global.expect = chai.expect
global.sinon = sinon

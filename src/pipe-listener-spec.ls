require! {
  fs
  './pipe-listener': PipeListener
  '../spec/spec_helper'
  rimraf
}


describe 'PipeListener' ->

  describe 'listen' ->

    before-each (done) ->
      rimraf.sync 'tmp'
      fs.mkdir-sync 'tmp'
      @pipe-listener = new PipeListener 'tmp/.tertestrial.tmp'
        ..listen done

    after-each ->
      @pipe-listener.cleanup!


    context 'invalid json' ->

      before-each (done) ->
        @pipe-listener.on 'command-parse-error', (@error) ~> done!
        @pipe-listener.on 'error', done
        fs.appendFile 'tmp/.tertestrial.tmp', '{'

      specify 'triggers a command-parse-error event' ->
        expect(@error).to.include """
          Invalid command: {
          SyntaxError:
          """


    context 'single json command' ->

      before-each (done) ->
        @pipe-listener.on 'command-received', (@command) ~> done!
        @pipe-listener.on 'error', done
        fs.appendFile 'tmp/.tertestrial.tmp', '{"a":1}'

      specify 'triggers a command-received event' ->
        expect(@command).to.eql a: 1


    context 'leading newline' ->

      before-each (done) ->
        @pipe-listener.on 'command-received', (@command) ~> done!
        @pipe-listener.on 'error', done
        fs.appendFile 'tmp/.tertestrial.tmp', '\n{"a":1}'

      specify 'triggers a command-received event' ->
        expect(@command).to.eql a: 1


    context 'trailing newline' ->

      before-each (done) ->
        @pipe-listener.on 'command-received', (@command) ~> done!
        @pipe-listener.on 'error', done
        fs.appendFile 'tmp/.tertestrial.tmp', '{"a":1}\n'

      specify 'triggers a command-received event' ->
        expect(@command).to.eql a: 1


    context 'multiple json commands' ->

      before-each (done) ->
        @pipe-listener.on 'command-received', (@command) ~> done!
        @pipe-listener.on 'error', done
        fs.appendFile 'tmp/.tertestrial.tmp', '{"a":1}\n{"b":2}'

      specify 'triggers a command-received event with just the last command' ->
        expect(@command).to.eql b: 2

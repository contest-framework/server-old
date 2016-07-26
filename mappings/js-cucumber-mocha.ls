mappings:
  feature:
    test-file: ({filename}) -> "cucumber-js #{filename}"
    test-line: ({filename, line}) -> "cucumber-js #{filename}:#{line}"
  js:
    test-file: ({filename}) -> "mocha #{filename}"
  coffee:
    test-file: ({filename}) -> "mocha --compilers coffee:coffee-script #{filename}"
  ls:
    test-file: ({filename}) -> "mocha --compilers ls:livescript #{filename}"

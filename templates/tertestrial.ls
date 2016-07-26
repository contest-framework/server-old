mappings:

  # mappings for files with the extension ".feature"
  feature:

    # define the command to test a full ".feature" file using cucumber-js
    test-file: ({filename}) -> "cucumber-js #{filename}"

    # define the command to test a ".feature" file at a certain line using cucumber-js
    test-line: ({filename, line}) -> "cucumber-js #{filename}:#{line}"

  # mappings for files with the extension ".js"
  js:
    test-file: ({filename}) -> "mocha #{filename}"

  coffee:
    test-file: ({filename}) -> "mocha --compilers coffee:coffee-script #{filename}"

  ls:
    test-file: ({filename}) -> "mocha --compilers ls:livescript #{filename}"

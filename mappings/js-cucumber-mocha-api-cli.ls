api-mapping =
  feature:
    test-file: ({filename}) -> "cuc-api #{filename}"
    test-line: ({filename, line}) -> "cuc-api #{filename}:#{line}"
  js:
    test-file: ({filename}) -> "mocha #{filename}"
  coffee:
    test-file: ({filename}) -> "mocha --compilers coffee:coffee-script #{filename}"
  ls:
    test-file: ({filename}) -> "mocha --compilers ls:livescript #{filename}"

cli-mapping =
  feature:
    test-file: ({filename}) -> "cuc-cli #{filename}"
    test-line: ({filename, line}) -> "cuc-cli #{filename}:#{line}"
  js:
    test-file: ({filename}) -> "mocha #{filename}"
  coffee:
    test-file: ({filename}) -> "mocha --compilers coffee:coffee-script #{filename}"
  ls:
    test-file: ({filename}) -> "mocha --compilers ls:livescript #{filename}"

all-mapping =
  feature:
    test-file: ({filename}) -> "cuc-api #{filename} && cuc-cli #{filename}"
    test-line: ({filename, line}) -> "cuc-api #{filename}:#{line} && cuc-cli #{filename}:#{line}"
  js:
    test-file: ({filename}) -> "mocha #{filename}"
  coffee:
    test-file: ({filename}) -> "mocha --compilers coffee:coffee-script #{filename}"
  ls:
    test-file: ({filename}) -> "mocha --compilers ls:livescript #{filename}"


mappings:
  * all-mapping
  * api-mapping
  * cli-mapping

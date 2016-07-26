return {
  "mappings": {

    // mappings for files with the extension ".feature"
    "feature": {

      // define the command to test a full ".feature" file using cucumber-js
      "testFile": function(args) { return "cucumber-js " + args.filename },

      // define the command to test a ".feature" file at a certain line using cucumber-js
      "testLine": function(args) { return "cucumber-js " + args.filename + ":" + args.line }
    },

    // mappings for files with the extension ".js"
    "js": {

      // here we specify that we test JavaScript files using MochaJS
      "testFile": function(args) { return "mocha " + args.filename }
    },

    "coffee": {
      "testFile": function(args) { return "mocha --compilers coffee:coffee-script " + args.filename }
    },

    "ls": {
      "testFile": function(args) { return "mocha --compilers ls:livescript " + args.filename }
    }
  }
}

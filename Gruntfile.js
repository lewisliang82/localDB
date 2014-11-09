// Generated by CoffeeScript 1.8.0
module.exports = function(grunt) {
  'use strict';
  var convert;
  convert = function(name, path, contents) {
    var item, k, moduleName, pkg, v;
    pkg = grunt.file.readJSON('package.json');
    while (true) {
      item = contents.match(/(.+) = require\('.+'\);/);
      if (item == null) {
        break;
      }
      for (k in item) {
        v = item[k];
        if (k === "1") {
          moduleName = v.trim();
        }
        contents = contents.replace(new RegExp("(var.*) " + moduleName + ",?"), "$1");
        contents = contents.replace(/(var.*), *;/, "$1;");
      }
      contents = contents.replace(/(.+) = require\('.+'\).*\n/, "");
    }
    contents = contents.replace(/.*Generated by CoffeeScript.*\n/, "");
    contents = contents.replace(/return module.exports = (.*);\n/, "self.$1 = $1;");
    contents = contents.replace(/(.+) = require\(['"]$/, "");
    contents = contents.replace(/define\([^{]*?{/, "").replace(/\}\);[^}\w]*$/, "");
    contents = contents.replace(/define\(\[[^\]]+\]\)[\W\n]+$/, "");
    contents = contents.replace(/LocalDB.version = \'\';/, "LocalDB.version = '" + pkg.version + "'");
    contents = "(function(self){\n" + contents;
    contents += "\n})(this);\n";
    return contents;
  };
  require('load-grunt-tasks')(grunt);
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %>\n' + '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' + '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' + ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',
    karma: {
      unit: {
        configFile: 'karma.conf.coffee',
        singleRun: true
      }
    },
    clean: {
      build: ['dist/<%= pkg.version %>']
    },
    requirejs: {

      /* r.js exmaple build file
       *  https://github.com/jrburke/r.js/blob/master/build/example.build.js
       */
      compile: {
        options: {
          name: "localdb",
          baseUrl: "src/",
          out: "dist/<%= pkg.version %>/localdb.js",
          optimize: 'none',
          findNestedDependencies: true,
          skipSemiColonInsertion: true,
          wrap: {
            startFile: "src/wrap.start",
            endFile: "src/wrap.end"
          },
          onBuildWrite: convert
        }
      }
    },
    copy: {
      main: {
        files: {
          "dist/<%= pkg.version %>/localdb-sea.js": ["dist/<%= pkg.version %>/localdb.js"]
        },
        options: {
          process: function(content, srcpath) {
            return "define(function(require, exports, module) {" + content + "});";
          }
        }
      }
    },
    uglify: {
      standalone: {
        files: {
          "dist/<%= pkg.version %>/localdb.min.js": ["dist/<%= pkg.version %>/localdb.js"]
        },
        options: {
          banner: '<%= banner %>',
          preserveComments: false,
          sourceMap: true,
          sourceMapName: "dist/<%= pkg.version %>/localdb.min.map",
          report: "min",
          beautify: {
            "ascii_only": true
          },
          compress: {
            "hoist_funs": false,
            loops: false,
            unused: false
          }
        }
      },
      sea: {
        files: {
          "dist/<%= pkg.version %>/localdb-sea.min.js": ["dist/<%= pkg.version %>/localdb-sea.js"]
        },
        options: {
          banner: '<%= banner %>',
          preserveComments: false,
          sourceMap: true,
          sourceMapName: "dist/<%= pkg.version %>/localdb-sea.min.map",
          report: "min",
          beautify: {
            "ascii_only": true
          },
          compress: {
            "hoist_funs": false,
            loops: false,
            unused: false
          }
        }
      }
    },
    coveralls: {
      options: {
        debug: true,
        coverage_dir: 'coverage/',
        dryRun: process.env.TRAVIS != null ? false : true,
        force: true,
        recursive: true
      }
    }
  });
  grunt.registerTask('test', ['karma', 'coveralls']);
  grunt.registerTask('build', ['test', 'clean:build', 'requirejs', 'copy', 'uglify:*']);
  grunt.registerTask('default', ['test']);
};

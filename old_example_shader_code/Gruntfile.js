module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        files: {
            'build/BT2D.minified.js':
                ['lib/scene/*.js',
                 'lib/light/*.js',
                 'lib/rendering/*.js',
                 'lib/scene/*.js',
                 'lib/surfaces/*.js',
                 'lib/test_scene/*.js',
                 'lib/tracers/*.js',
            ]
        }
      }
    },
    
    includeSource: {
        options: {
            basePath: 'lib',
            
            templates: {
              html: {
                js: '<script src="{filePath}"></script>',
                css: '<link rel="stylesheet" type="text/css" href="{filePath}" />',
              },
              haml: {
                js: '%script{src: "{filePath}"}/',
                css: '%link{href: "{filePath}", rel: "stylesheet"}/'
              },      
              jade: {
                js: 'script(src="{filePath}", type="text/javascript")',    
                css: 'link(href="{filePath}", rel="stylesheet", type="text/css")'
              },
              scss: {
                scss: '@import "{filePath}";',
                css: '@import "{filePath}";',
              },
              less: {
                less: '@import "{filePath}";',
                css: '@import "{filePath}";',
              },
              ts: {
                ts: '/// <reference path="{filePath}" />'
              }
            }
          },
          myTarget: {
             files: {
                'index2.html' : 'index.tpl.html',
            }
          }
    },
    
  });

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-include-source');

  // Default task(s).
  grunt.registerTask('default', ['includeSource']);

};
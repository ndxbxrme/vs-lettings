module.exports = (grunt) ->
  require('load-grunt-tasks') grunt
  require('grunt-ndxmin') grunt
  bower = require('./bower.json')
  pkg = require('./package.json')
  grunt.initConfig
    express:
      options: {}
      web:
        options:
          script: 'server/app.js'
          opts: ['--expose-gc']
      dist:
        options:
          script: 'server/app.js'
          opts: ['--expose-gc']
          node_env: 'production'
          port: 3001
    watch:
      frontend:
        options:
          spawn: true
          livereload: +(process.env.LIVERELOAD_PORT or 35729)
        files: ['src/client/**/*.*']
        tasks: ['buildClient']
      web:
        files: ['src/server/**/*.coffee']
        tasks: ['buildWeb', 'express:web']
        options:
          spawn: false
          atBegin: true
    coffee:
      options:
        sourceMap: false
      client:
        files: [{
          expand: true
          cwd: 'src'
          src: ['client/**/*.coffee']
          dest: 'build'
          ext: '.js'
        }]
      web:
        files: [{
          expand: true
          cwd: 'src'
          src: ['server/**/*.coffee']
          dest: ''
          ext: '.js'
        }]
    jade:
      options:
        pretty: true
        data: ->
          package: pkg
      default:
        files: [{
          expand: true
          cwd: 'src'
          src: ['**/*.jade']
          dest: 'build'
          ext: '.html'
        }]
    injector:
      default:
        files:
          "build\/client\/index.html": ['build/client/**/*.js', 'build/client/**/*.css']
    stylus:
      default:
        files:
          "build/client/app.css": "src/client/**/*.stylus"
    wiredep:
      options:
        directory: 'bower_components'
      target:
        src: 'build/client/index.html'
    clean:
      client: 'build/client'
      web: 'server'
      dist: 'dist'
      build: 'build'
      tmp: '.tmp'
      html: 'build/client/*/**/*.html'
    filerev:
      build:
        src: [
          'build/client/**/*.js'
          'build/client/**/*.css'
        ]
    usemin:
      html: ['build/client/**/*.html']
      js: ['build/client/**/*.js']
      css: ['build/client/**/*.css']
      options:
        assetsDirs: ['build/client']
        patterns:
          js: [
            /'([^']+\.html)'/
          ]
    ngtemplates:
      options:
        module: 'vs-lettings'
      main:
        cwd: 'build/client'
        src: [
          'routes/**/*.html'
          'directives/**/*.html'
        ]
        dest: 'build/client/templates.js'
    copy:
      html:
        files: [{
          expand: true
          cwd: 'src/client'
          dest: 'build/client'
          src: [
            '*/**/*.html'
          ]
        }]
      dist:
        files: [{
          expand: true
          cwd: '.tmp'
          dest: 'dist'
          src: [
            '**/*.*'
          ]
        }]
    file_append:
      main:
        files: [{
          append: "<script src=\"http://#{process.env.LIVERELOAD_SERVER or 'localhost'}:#{process.env.LIVERELOAD_PORT or 35729}/livereload.js\" type=\"text/javascript\"></script>"
          input: 'build/client/index.html'
          output: 'build/client/index.html'
        }]
    ngmin: dist: files: [ {
      expand: true
      cwd: 'build/client'
      src: '**/*.js'
      dest: 'build/client'
    } ]
    ndxmin:
      options:
        base: 'build/client'
        dest: '.tmp'
        ignoreExternal: false
      all:
        html: ['build/client/index.html']
    'ndx-script-inject':
      options:
        bower: bower
        pkg: pkg
      all:
        html: ['build/client/index.html']
  grunt.registerTask 'stuff', [
    'ndxmin'
  ]
  grunt.registerTask 'do_build', [
    'clean:client'
    'coffee:client'
    'jade'
    'stylus'
    'copy:html'
    'ngtemplates'
    'filerev'
    'ndx-script-inject'
    'usemin'
    'clean:html'
  ]
  grunt.registerTask 'buildClient', [
    'do_build'
    'file_append'
  ]
  grunt.registerTask 'buildWeb', [
    'clean:web'
    'coffee:web'
  ]
  grunt.registerTask 'build', [
    'do_build'
    'buildWeb'
    'ndxmin'
    'clean:dist'
    'copy:dist'
    'clean:tmp'
    'clean:build'
  ]
  grunt.registerTask 'serve', [
    'build'
    'express:dist'
    'keepalive'
  ]
  grunt.registerTask 'default', [
    'buildClient'
    'buildWeb'
    #'express:web'
    'watch'
  ]
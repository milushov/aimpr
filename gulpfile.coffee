gulp      = require 'gulp'
$         = require('gulp-load-plugins')
  lazy:    true
  pattern: '*' # just for main-bower-files

pkg       = require './package.json'
banner    = "/*! #{ pkg.name } #{ pkg.version } */\n"
dest_path = 'build/public'

gulp.task 'templates', ->
  gulp.src 'src/templates/index.jade'
    .pipe $.jade(pretty: true)
    .pipe $.rename('index.html')
    .pipe gulp.dest('build')

gulp.task 'coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe $.coffee(bare: true).on('error', $.util.log)
    .pipe $.plumber()
    .pipe gulp.dest('build')
    .pipe $.connect.reload()

gulp.task 'styles', ->
  gulp.src 'src/**/*.sass'
   .pipe $.rubySass(style: 'compressed')
    .pipe $.plumber()
    .pipe gulp.dest('build')
    .pipe $.connect.reload()

gulp.task 'uglify', ->
  gulp.src 'build/**/*.js'
    .pipe $.uglify()
    .pipe $.plumber()
    .pipe $.header(banner)
    .pipe $.rename('app.min.js')
    .pipe gulp.dest('build')

gulp.task 'js', ->
  gulp.start 'coffee', ->
    gulp.start 'uglify', ->

gulp.task 'html', ->
  gulp.src 'build/*.html'
    .pipe $.connect.reload()

gulp.task 'connect', ->
  $.connect.server
    livereload: true
    root: 'build'
    https: true

# http://stackoverflow.com/a/24808013/1171144
# grab libraries files from bower_components, minify and push in /public
gulp.task 'libs', ->

  jsFilter   = $.filter('*.js')
  cssFilter  = $.filter('*.css')
  fontFilter = $.filter(['*.eot', '*.woff', '*.svg', '*.ttf'])

  gulp.src($.mainBowerFiles())
    .pipe(jsFilter)
    .pipe(gulp.dest(dest_path + '/js/vendor'))
    .pipe($.uglify())
    .pipe($.rename(suffix: '.min'))
    .pipe(gulp.dest(dest_path + '/js/vendor'))
    .pipe(jsFilter.restore())

    .pipe(cssFilter)
    .pipe(gulp.dest(dest_path + '/css'))
    .pipe($.minifyCss())
    .pipe($.rename(suffix: '.min'))
    .pipe(gulp.dest(dest_path + '/css'))
    .pipe(cssFilter.restore())

    .pipe(fontFilter)
    .pipe($.flatten())
    .pipe(gulp.dest(dest_path + '/fonts'))

gulp.task 'default', ->
  gulp.start ['html', 'styles', 'js', 'connect']

  gulp.watch '**/*.jade', ['templates']
  gulp.watch '**/*.html', ['html']
  gulp.watch '**/*.coffee', ['js']
  gulp.watch '**/*.sass', ['styles']
  #gulp.watch 'package.json', ['js']
  gulp.watch 'bower.json', ['libs']


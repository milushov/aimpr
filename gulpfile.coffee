gulp       = require 'gulp'
jade       = require 'gulp-jade'
coffee     = require 'gulp-coffee'
sass       = require 'gulp-ruby-sass'
gutil      = require 'gulp-util'
uglify     = require 'gulp-uglify'
header     = require 'gulp-header'
rename     = require 'gulp-rename'
plumber    = require 'gulp-plumber'

livereload = require 'gulp-livereload'
connect    = require 'gulp-connect'

flatten        = require 'gulp-flatten'
gulpFilter     = require 'gulp-filter'
minifycss      = require 'gulp-minify-css'
mainBowerFiles = require 'main-bower-files'


pkg       = require './package.json'
banner    = "/*! #{ pkg.name } #{ pkg.version } */\n"
dest_path = 'build/public'

gulp.task 'templates', ->
  gulp.src 'src/templates/index.jade'
    .pipe jade(pretty: true)
    .pipe rename('index.html')
    .pipe gulp.dest('build')

gulp.task 'coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe gulp.dest('build')
    .pipe connect.reload()

gulp.task 'styles', ->
  gulp.src 'src/**/*.sass'
    .pipe sass(style: 'compressed')
    .pipe plumber()
    .pipe gulp.dest('build')
    .pipe connect.reload()

gulp.task 'uglify', ->
  gulp.src 'build/**/*.js'
    .pipe uglify()
    .pipe header(banner)
    .pipe rename('app.min.js')
    .pipe gulp.dest('build')

gulp.task 'js', ->
  gulp.run 'coffee', ->
    gulp.run 'uglify', ->

gulp.task 'html', ->
  gulp.src 'build/*.html'
    .pipe connect.reload()

gulp.task 'connect', ->
  connect.server
    livereload: true
    root: 'build'
    https: true

# http://stackoverflow.com/a/24808013/1171144
# grab libraries files from bower_components, minify and push in /public
gulp.task 'libs', ->

  jsFilter   = gulpFilter('*.js')
  console.log(jsFilter)
  cssFilter  = gulpFilter('*.css')
  fontFilter = gulpFilter(['*.eot', '*.woff', '*.svg', '*.ttf'])

  gulp.src(mainBowerFiles())
    .pipe(jsFilter)
    .pipe(debug(verbose: true))
    .pipe(gulp.dest(dest_path + '/js/vendor'))
    .pipe(uglify())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest(dest_path + '/js/vendor'))
    .pipe(jsFilter.restore())

    .pipe(cssFilter)
    .pipe(gulp.dest(dest_path + '/css'))
    .pipe(minifycss())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest(dest_path + '/css'))
    .pipe(cssFilter.restore())

    .pipe(fontFilter)
    .pipe(flatten())
    .pipe(gulp.dest(dest_path + '/fonts'))

gulp.task 'default', ->
  gulp.run 'connect'

  gulp.watch '**/*.jade', ['templates']
  gulp.watch '**/*.html', ['html']
  gulp.watch '**/*.coffee', ['js']
  gulp.watch '**/*.sass', ['styles']
  #gulp.watch 'package.json', ['js']
  gulp.watch 'bower.json', ['libs']


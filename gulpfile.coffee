gulp      = require 'gulp'
$         = require('gulp-load-plugins')
  lazy:    true
  pattern: '*' # just for main-bower-files

pkg       = require './package.json'
cur_date  = -> new Date().toLocaleString()
banner    = -> "/*! #{ pkg.name } #{ pkg.version } #{cur_date()} */\n"
dest_path = 'build/'

gulp.task 'clean', (cb) -> $.del 'build', cb
gulp.task 'remove_images', (cb) -> $.del 'build/images', cb
gulp.task 'remove_libs', (cb) -> $.del 'build/libs', cb

gulp.task 'views', ->
  gulp.src 'app/**/*.jade'
    .pipe $.plumber()
    .pipe $.jade(pretty: true)
    .pipe gulp.dest('build')
    .pipe $.connect.reload()

gulp.task 'templates', ->
  gulp.src ['!build/index.html', 'build/**/*.html']
    .pipe $.angularTemplatecache 'templates.js', standalone:true
    .pipe $.plumber()
    .pipe gulp.dest('build')

gulp.task 'coffee', ->
  gulp.src 'app/**/*.coffee'
    .pipe $.plumber()
    .pipe $.coffee(bare: true)
    .on('error', $.util.log)
    .pipe gulp.dest('build')

# combine all js files of the build
gulp.task 'js', ->
  gulp.src 'build/scripts/**/*.js'
    #.pipe $.jshint()
    #.pipe $.jshint.reporter('jshint-stylish')
    .pipe $.concat('app.js')
    .pipe $.plumber()
    .pipe $.header(banner())
    .pipe gulp.dest('build')
    .pipe $.connect.reload()

# for production
gulp.task 'uglify', ->
  gulp.src 'build/app.js'
    .pipe $.uglify()
    .pipe $.plumber()
    .pipe $.rename(suffix: '.min')
    .pipe gulp.dest('build')

gulp.task 'scripts', ->
  $.runSequence 'coffee', 'js', 'uglify'

gulp.task 'styles', ->
  gulp.src 'app/**/*.sass'
    .pipe $.plumber()
    .pipe $.rubySass()
    .pipe $.autoprefixer('last 3 version')
    .pipe $.concat('app.css')
    .pipe gulp.dest('build')
    .pipe $.minifyCss()
    .pipe $.rename(suffix: '.min')
    .pipe gulp.dest('build')
    .pipe $.connect.reload()

gulp.task 'html', ->
  gulp.src 'build/*.html'
    .pipe $.connect.reload()

gulp.task 'connect', ->
  $.connect.server
    livereload: true
    root: 'build'
    https: true

gulp.task 'images', ['remove_images'], ->
  gulp.src 'app/images/**/*'
    .pipe gulp.dest('build/images')

gulp.task 'build', ->
  $.runSequence 'views', 'templates', 'libs'
  gulp.start ['styles', 'scripts', 'images']

gulp.task 'libs', ['remove_libs'], ->
  $.runSequence 'get_libs', 'compile_libs'

# http://stackoverflow.com/a/24808013/1171144
# grab libraries files from bower_components, minify and push in /public
gulp.task 'get_libs', ->

  jsFilter   = $.filter '*.js'
  cssFilter  = $.filter '*.css'
  fontFilter = $.filter ['*.eot', '*.woff', '*.svg', '*.ttf']

  gulp.src($.mainBowerFiles())
    .pipe $.plumber()

    .pipe jsFilter
    .pipe gulp.dest(dest_path + 'libs/js')
    .pipe jsFilter.restore()

    .pipe cssFilter
    .pipe gulp.dest(dest_path + 'libs/css')
    .pipe cssFilter.restore()

    .pipe fontFilter
    .pipe gulp.dest(dest_path + 'libs/fonts')

gulp.task 'compile_libs', ->

  jsFilter   = $.filter '**/*.js'
  cssFilter  = $.filter '**/*.css'
  fontFilter = $.filter \
    ['*.eot', '*.woff', '*.svg', '*.ttf'].map -> "**/#{@}"

  gulp.src 'build/libs/**/*.*'
    .pipe $.plumber()
    .pipe jsFilter
    .pipe $.concat('aimpr-lib.js')
    #.pipe $.debug()
    .pipe gulp.dest(dest_path + 'libs/js')
    .pipe $.uglify()
    .pipe $.rename(suffix: '.min')
    .pipe gulp.dest(dest_path + 'libs/js')
    .pipe jsFilter.restore()

    .pipe cssFilter
    .pipe $.concat('aimpr-lib.css')
    .pipe gulp.dest dest_path + 'libs/css'
    .pipe $.minifyCss()
    .pipe $.rename(suffix: '.min')
    .pipe gulp.dest(dest_path + 'libs/css')
    .pipe cssFilter.restore()

    .pipe fontFilter
    .pipe $.flatten()
    .pipe gulp.dest(dest_path + 'libs/fonts')

gulp.task 'default', ['clean'], ->
  gulp.start ['build', 'html', 'connect']

  gulp.watch 'app/**/*.jade', -> $.runSequence 'views'
  gulp.watch 'app/**/*.html', ['html', 'templates']
  gulp.watch 'app/**/*.coffee', ['scripts']
  gulp.watch 'app/**/*.sass', ['styles']
  gulp.watch 'app/images/**/*', ['images']
  gulp.watch 'bower_components', ['libs']


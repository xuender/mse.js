gulp = require 'gulp'
serve = require 'gulp-serve'
livereload = require 'gulp-livereload'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
karma = require('karma').server

gulp.task('coffee', ->
  gulp.src([
    'src/set.coffee'
    'src/spider.coffee'
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('spider.js'))
    .pipe(gulp.dest('.'))
    .pipe(livereload())
  gulp.src([
    'src/set.coffee'
    'src/mini.coffee'
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('mse.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest('.'))
    .pipe(livereload())
)

gulp.task('watch', ->
  serve(
    port: 8000
  )()
  livereload.listen()
  gulp.watch('src/**/*.coffee', ['coffee'])
  gulp.watch("*.html").on 'change', livereload.changed

  karma.start(
    configFile: __dirname + '/karma.conf.js',
  )
)

gulp.task('test', ->
  karma.start(
    configFile: __dirname + '/karma.conf.js',
    singleRun: true
  )
)

gulp.task('default',['coffee'])


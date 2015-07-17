gulp = require 'gulp'
serve = require 'gulp-serve'
livereload = require 'gulp-livereload'

gulp.task('watch', ->
  serve(
    port: 8001
  )()
  livereload.listen()
  gulp.watch("**/*.html").on 'change', livereload.changed
)

gulp.task('default',['watch'])

var bower = require('gulp-bower');
var cjsx = require('gulp-cjsx');
var gulp = require('gulp');
var jade = require('gulp-jade');
var sass = require('gulp-sass');
var gutil = require('gulp-util');
var path = require('path');

if (process.env.NODE_ENV != 'development' &&
  process.env.NODE_ENV !== undefined) {
  gulp.task('default');
  return;
}

var bowerDir = './bower_components';

gulp.task('default', ['bower', 'cjsx', 'images', 'sass', 'jade', 'watch']);

gulp.task('bower', function() {
  return bower()
    .on('error', gutil.log)
    .pipe(gulp.dest(bowerDir));
});

gulp.task('cjsx', function() {
  gulp.src('./src/coffee/**/*.coffee')
    .pipe(cjsx({ bare: true }))
    .on('error', gutil.log)
    .pipe(gulp.dest('./public/js/'));
});

gulp.task('images', function() {
  gulp.src('./images/**/*')
    .pipe(gulp.dest('./public/images/'));
});

gulp.task('sass', function() {
  options = {
    includePaths: [
      bowerDir + '/bourbon/app/assets/stylesheets',
      bowerDir + '/bootstrap-sass/assets/stylesheets'
    ]
  };

  gulp.src('./src/scss/**/*.scss')
    .pipe(sass(options).on('error', sass.logError))
    .pipe(gulp.dest('./public/css'));
});

gulp.task('jade', function() {
  options = {
    pretty: true
  };

  gulp.src('./src/jade/**/*.jade')
    .pipe(jade(options))
    .on('error', gutil.log)
    .pipe(gulp.dest('./public/'));
});

gulp.task('watch', function() {
  gulp.watch('./src/coffee/**/*.coffee', ['cjsx']);
  gulp.watch('./src/jade/**/*.jade', ['jade']);
  gulp.watch('./images/**/*', ['images']);
  gulp.watch('./src/scss/**/*.scss', ['sass']);
});


var bower = require('gulp-bower');
var concat = require('gulp-concat');
var cjsx = require('gulp-cjsx');
var gulp = require('gulp');
var gutil = require('gulp-util');
var jade = require('gulp-jade');
var merge = require('merge-stream');
var sass = require('gulp-sass');
var path = require('path');

if (process.env.NODE_ENV != 'development' &&
  process.env.NODE_ENV !== undefined) {
  gulp.task('default');
  return;
}

var bowerDir = './bower_components';

gulp.task('default', [
  'bower',
  'css',
  'fonts',
  'images',
  'jade',
  'js',
  'vendorjs',
  'watch'
]);

gulp.task('bower', function() {
  return bower()
    .on('error', gutil.log)
    .pipe(gulp.dest(bowerDir));
});

gulp.task('vendorjs', function() {
  var vendorFiles = [
    bowerDir + '/react/react-with-addons.min.js',
    bowerDir + '/jquery/dist/jquery.min.js',
  ];

  gulp.src(vendorFiles)
    .pipe(concat('vendor.min.js'))
    .pipe(gulp.dest('./public/js/'));
});

gulp.task('js', function() {
  gulp.src('./src/coffee/**/*.coffee')
    .pipe(cjsx({ bare: true }))
    .on('error', gutil.log)
    .pipe(concat('application.min.js'))
    .pipe(gulp.dest('./public/js/'));
});

gulp.task('images', function() {
  gulp.src('./images/**/*')
    .pipe(gulp.dest('./public/images/'));
});

gulp.task('fonts', function() {
  var vendorFiles = [
    bowerDir + '/font-awesome/fonts/fontawesome-webfont.eot',
    bowerDir + '/font-awesome/fonts/fontawesome-webfont.svg',
    bowerDir + '/font-awesome/fonts/fontawesome-webfont.ttf',
    bowerDir + '/font-awesome/fonts/fontawesome-webfont.woff',
    bowerDir + '/font-awesome/fonts/fontawesome-webfont.woff2',
  ];

  gulp.src(vendorFiles)
    .pipe(gulp.dest('./public/fonts/'));
});

gulp.task('css', function() {
  var vendorFiles = [
    bowerDir + '/font-awesome/css/font-awesome.min.css',
  ];

  var options = {
    includePaths: [
      bowerDir + '/bourbon/app/assets/stylesheets',
      bowerDir + '/bootstrap-sass/assets/stylesheets'
    ],
    outputStyle: 'compressed'
  };

  var vendorStream = gulp.src(vendorFiles);
  var appStream = gulp.src('./src/scss/**/*.scss')
    .pipe(sass(options).on('error', sass.logError));

  merge(vendorStream, appStream)
    .pipe(concat('application.min.css'))
    .pipe(gulp.dest('./public/css'));
});

gulp.task('jade', function() {
  options = {
    pretty: false
  };

  gulp.src('./src/jade/**/*.jade')
    .pipe(jade(options))
    .on('error', gutil.log)
    .pipe(gulp.dest('./public/'));
});

gulp.task('watch', function() {
  gulp.watch('./src/coffee/**/*.coffee', ['js']);
  gulp.watch('./src/jade/**/*.jade', ['jade']);
  gulp.watch('./src/scss/**/*.scss', ['css']);
  gulp.watch('./images/**/*', ['images']);
});


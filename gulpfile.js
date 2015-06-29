var gulp       = require('gulp'),
    install    = require('gulp-install'),
    run        = require('gulp-run'),
    source     = require('vinyl-source-stream'),
    purescript = require('gulp-purescript'),
    include    = require('gulp-include'),
    rename     = require('gulp-rename');

gulp.task('restore-packages', function() { 
    return gulp.src(['./package.json', './bower.json'])
	.pipe(install());
});

gulp.task('build', function(cb) {
    run('pulp build').exec();
});

gulp.task('test', ['build'], function(cb) {
    run('pulp test').exec();
});

gulp.task('produce-expresso', function(cb){
    run('~/bin/psc-bundle ~/Dropbox/js/pulpparse/output/**/*.js '
        + ' -m Expresso.Operations'
        + ' -m Expresso.Parser'
        + ' -m Expresso.Parser.Data'
        + ' -m Data.String'
        + ' --namespace Ryvus'
        + ' > expresso-raw.js')
        .exec();
});

gulp.task('wrap-purescript', function(cb) {
    return gulp.src('index-template.js')
        .pipe(include())
        .pipe(rename('index.js'))
        .pipe(gulp.dest('.'));
});

gulp.task('default', ['restore-packages', 'wrap-purescript']);

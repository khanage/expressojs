var
gulp        = require('gulp'),
install     = require('gulp-install'),
run         = require('gulp-run'),
source      = require('vinyl-source-stream'),
purescript  = require('gulp-purescript'),
include     = require('gulp-include'),
rename      = require('gulp-rename'),
bump        = require('gulp-bump'),
git         = require('gulp-git'),
tag_version = require('gulp-tag-version'),
filter      = require('gulp-filter')
;

gulp.task('restore-packages', function() { 
    return gulp.src(['./package.json', './bower.json'])
	.pipe(install());
});

gulp.task('build', function(cb) {
    run('pulp build').exec(cb);
});

gulp.task('test', ['build'], function(cb) {
    run('pulp test').exec(cb);
});

gulp.task('produce-expresso', ['test', 'build'], function(cb){
    run('~/bin/psc-bundle ~/Dropbox/js/pulpparse/output/**/*.js '
        + ' -m Expresso.Operations'
        + ' -m Expresso.Parser'
        + ' -m Expresso.Parser.Data'
        + ' -m Data.String'
        + ' --namespace Ryvus'
        + ' > expresso-raw.js')
        .exec(cb);
});

gulp.task('wrap-purescript', ['produce-expresso'], function(cb) {
    return gulp.src('index-template.js')
        .pipe(include())
        .pipe(rename('index.js'))
        .pipe(gulp.dest('.'));
});

gulp.task('bump', function() {
    gulp.src(['./bower.json', './package.json'])
        .pipe(bump({type:'patch'}))
        .pipe(gulp.dest('./'))
        .pipe(git.commit('bump package version'))
        .pipe(filter('bower.json'))
        .pipe(tag_version());
});

gulp.task('default', ['wrap-purescript']);

var gulp = require('gulp'),
    install = require('gulp-install'),
    exec = require('child_process').exec,
    browserify = require('browserify'),
    source = require('vinyl-source-stream');

gulp.task('restore-packages', function() { 
    return gulp.src(['./bower.json'])
	.pipe(install());
});

gulp.task('pulp', function(cb) {
    return exec('pulp build', function(err, stdout, stderr) {
        cb(err);
    });
});


gulp.task('test', function(cb) {
    return exec('pulp test', function(err, stdout, stderr) {
        cb(err);
    });
});

gulp.task('copy-porcelein', function(cb) {
    return gulp.src ('./src/Expresso/index.js')
        .pipe (gulp.dest ('./output/Expresso/'));
});

gulp.task('default', ['restore-packages', 'pulp', 'test', 'copy-porcelein']);

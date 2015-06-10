var gulp = require('gulp'),
    install = require('gulp-install'),
    exec = require('child_process').exec,
    browserify = require('browserify'),
    source = require('vinyl-source-stream');

gulp.task('restore-packages', function() { 
    return gulp.src(['./package.json'])
	.pipe(install());
});

gulp.task('pulp', function(cb) {
    return exec('pulp build -o node_modules', function(err, stdout, stderr) {
        cb(err);
    });
});

gulp.task('browserify', function() {
    return browserify(['index.js']).bundle()
        .pipe(source('out.js'))
        .pipe(gulp.dest('./'));
});

gulp.task('build', ['restore-packages', 'pulp', 'browserify']);

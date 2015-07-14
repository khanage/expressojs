var
gulp        = require('gulp'),
install     = require('gulp-install'),
run         = require('gulp-run'),
source      = require('vinyl-source-stream'),
bump        = require('gulp-bump'),
git         = require('gulp-git'),
tag_version = require('gulp-tag-version'),
filter      = require('gulp-filter'),
browserify  = require('gulp-browserify'),
closure     = require('gulp-closure-compiler')
;

gulp.task('restore-packages', function() { 
    return gulp.src(['./package.json', './bower.json'])
	.pipe(install());
});

gulp.task('build', function(cb) {
    run("pulp build -o node_modules").exec(cb);
});

gulp.task('test', ['build'], function(cb) {
    run('pulp test').exec(cb);
});

gulp.task('package', ['test'], function() {
    gulp.src('src/Expresso/index.js')
        .pipe(browserify({
            standalone: 'expresso'
        }))
        // .pipe(closure({
        //     compilerPath: 'bower_components/closure-compiler/lib/vendor/compiler.jar',
        //     fileName: 'index.js',
        //     compilerFlags: {
        //         compilation_level: 'ADVANCED_OPTIMIZATIONS',
        //         common_js_entry_module: 'expresso'
        //     }
        // }))
        .pipe(gulp.dest('./'));
});

// gulp.task('test-package', [], function(cb) {
//     run('node -e "'
//         + 'var exp = require(\'./index.js\'); '
//         + 'var parse = exp.parse(\'Make.Holden.\'); '
//         + 'console.log(typeof(parse) != \"undefined\"); "'
//        ).exec(cb);
// });

gulp.task('bump', function() {
    gulp.src(['./bower.json', './package.json'])
        .pipe(bump({type:'patch'}))
        .pipe(gulp.dest('./'))
        .pipe(git.commit('bump package version'))
        .pipe(filter('bower.json'))
        .pipe(tag_version());
});

gulp.task('default', ['package']);

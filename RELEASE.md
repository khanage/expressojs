Releasing
=========

Gulp
----

Use the default gulp task to produce expresso. This currently uses a few hacks to produce something that can be called as a library (see the gulpfile).

Once this is built, commit changes (we use bower for distribution, so the files need to be in the repo).

Run `gulp bump` to change the version and add a tag.

Run `git push origin --tags` to "release" to github.

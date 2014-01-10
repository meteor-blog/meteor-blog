---
layout: default
username: BeDifferential
repo: meteor-blog
version: 0.2.6
desc: Gives you an basic, out-of-the-box blog at `/blog`

---
# Changelog

### v0.2.6

* Publish less data to blog index. **NOTE**: If you were using the `excerpt`
  helper before (`data.excerpt()`), it is now a field (`data.excerpt`).
* Replace EpicEditor with Ace Editor
* Add simple 'Load More' pagination
* Turn admin roles off by default

### v0.2.5

* Support for fast-render, if your app is using it
* Ensure there is an index on the `slug` field for posts
* Hide draft posts from crawlers
* Improve FB share link
* Make default theme more narrow
* Require `blogAdmin` role to be allowed to admin posts

### v0.2.4

* Remove 'urlify2' package (was crashing phantomjs in production)

### v0.2.3

* Take out Bootstrap 3 files by default (user must add manually)
* Fix bug getting blog post thumbnail
* Publish only blog authors

### v0.2.2

* Fix bug where every blog author was 'Mystery author' on blog index page
* Fix sorting of blogs on index and admin pages
* Fix flash status message
* Rename 'user' model to 'author' (to help avoid conflicts)

### v0.2.1

* Rename 404 template
* Allow user to override package templates
* Add experimental handlebar helpers for blog content
* Fix a few bugs related to joining blog to author

### v0.2.0

_NOTE: `iron-router` 0.6.x is not backwards-compatible with earlier versions_

* Upgrade iron-router to 0.6.1 and minimongoid to 0.8.3
* Add 404 template
* Rename some files/folders to match http://github.com/BeDifferential/meteor-boilerplate

### v0.1.0

* Initial release

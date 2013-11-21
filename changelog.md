---
layout: default
username: BeDifferential
repo: meteor-blog
version: 0.2.2
desc: Gives you an basic, out-of-the-box blog at `/blog`

---
# Changelog

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

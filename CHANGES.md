## Changelog

### v0.8.2

* Remove Bootstrap classes from public templates
* Improve 'notFound' handling
* Fix hero image in some cases
* Fix bug where you could not set the featured image before the post was saved

### v0.8.1

* Fix bug where author name was not showing up

### v0.8.0

**BREAKING CHANGES**:

 * Compatible only with Meteor `1.2` and higher.
 * Replaced `vsivsi:file-collection` with `cfs:gridfs`, so if you have any blog
   images stored in your database created by `file-collection`, then you must
   add `file-collection` to your app or they will be inaccessible.
 * CSS classes have been renamed and prefixed, so if you have any custom
   templates, styling may break.
 * Publications, subscriptions, and collections have all been renamed and
   prefixed. If you were doing anything clever with those, the clever thing may
   break.

**CHANGES**:

* Update to Meteor 1.2
* Reorganize & namespace all package publications, collections, and CSS classes (#82)
* Add Public, Private, and Draft modes for blog posts (#129)
* Add support for both Iron Router & Flow Router (#208)
* Allow user to set a custom base path (e.g. `/news` instead of `/blog`) for blog & admin (#94, #115)
* Upgrade `medium-editor` to 5.8.2, `medium-editor-insert-plugin` to 2.0.1 (fixes #198, #204)
* Replace `vsivsi:file-collection` with `cfs:gridfs` (fixes #183, #200)
* Fix minor bugs (#207, #203)

### v0.7.1

* Allow user to remove featured image ([#186](https://github.com/Differential/meteor-blog/issues/186))
* Use featured image for social sharing thumbnail if there is one ([#192](https://github.com/Differential/meteor-blog/issues/192))
* Add config to suppress loading CDN font-awesome ([#189](https://github.com/Differential/meteor-blog/issues/189))
* Fix crash caused by empty blog posts
* Fix `shareit` issue with Twitter cards ([#193](https://github.com/Differential/meteor-blog/pull/193))

### v0.7.0

* Upgrade `vsivsi:file-collection` to 1.1.0 ([#171](https://github.com/Differential/meteor-blog/issues/171) and [#180](https://github.com/Differential/meteor-blog/issues/180))

### v0.6.4

* Upgrade `medium-editor`, `medium-editor-insert-plugin` libs to 1.0 versions ([#164](https://github.com/Differential/meteor-blog/issues/164))
* Add Swift syntax highlighting ([#156](https://github.com/Differential/meteor-blog/issues/156))
* Allow user to upload a featured image for a post! ([#161](https://github.com/Differential/meteor-blog/pull/161))
* Optionally make drafts inaccessible to public via `Blog.config` ([#163](https://github.com/Differential/meteor-blog/pull/163))
* Fix bugs related to `side-comments.js` ([#157](https://github.com/Differential/meteor-blog/pull/157) and [#170](https://github.com/Differential/meteor-blog/pull/170))
* Upgrade `shareit` package and move to `lovetostrike:shareit` ([#155](https://github.com/Differential/meteor-blog/pull/155) and [#175](https://github.com/Differential/meteor-blog/pull/175))

### v0.6.3

* Fix pagination

### v0.6.2

* Allow user to upload blog images to S3 ([#141](https://github.com/Differential/meteor-blog/pull/141))
* Add 'Edit this Post' link to blog post ([#146](https://github.com/Differential/meteor-blog/pull/146))
* Make blog more SEO-friendly ([#137](https://github.com/Differential/meteor-blog/pull/137))
* Fix many bugs related to medium-editor ([#150](https://github.com/Differential/meteor-blog/pull/150), [#145](https://github.com/Differential/meteor-blog/pull/145), [#142](https://github.com/Differential/meteor-blog/pull/142))
* Fix bugs related to `side-comments.js` ([#143](https://github.com/Differential/meteor-blog/pull/143) and [#144](https://github.com/Differential/meteor-blog/pull/144))
* Upgrade `medium-editor`, `medium-editor-insert-plugin` libs

### v0.6.1

* Upgrade `fast-render` to fix DDP-related issues.
* Enable IR's `dataNotFound` hook only for blog post route, not globally ([#132](https://github.com/Differential/meteor-blog/issues/132))
* Fix bug where `Add Blog Post` button only edits first post ([#118](https://github.com/Differential/meteor-blog/issues/118))

### v0.6.0

_NOTE: `0.6.0` is probably only compatible with Meteor `1.0` and higher._

* Make compatible with Meteor `1.0`
* Fix bugs [#109](https://github.com/Differential/meteor-blog/issues/109), [#120](https://github.com/Differential/meteor-blog/issues/120), [#121](https://github.com/Differential/meteor-blog/issues/121), [#119](https://github.com/Differential/meteor-blog/issues/119).

### v0.5.10

* Fix lots of issues with medium editor and code blocks
* Fix bug where post body was showing up blank or wrong in editor

### v0.5.9

* Autosave blog post after 5 seconds of inactivity ([#90](https://github.com/Differential/meteor-blog/issues/90))
* Add [`fast-render`](https://atmospherejs.com/meteorhacks/fast-render) package by default ([#110](https://github.com/Differential/meteor-blog/pull/110))
* Use [`subs-manager`](https://atmospherejs.com/meteorhacks/subs-manager) to improve subscription performance ([#110](https://github.com/Differential/meteor-blog/pull/110))
* Fix bugs [#106](https://github.com/Differential/meteor-blog/pull/106), [#109](https://github.com/Differential/meteor-blog/issues/109)
* Upgrade `medium-editor`, `medium-editor-insert-plugin` libs

### v0.5.7

* Fix blank body bug (`0.5.5`), copy-and-paste bug (`0.5.6`) for good?

### v0.5.6

* Fix copy-and-paste bug broken in `0.5.5`
* Add prefix to `load-more` pager class to avoid potential conflicts ([#99](https://github.com/Differential/meteor-blog/issues/99))
* Fix CSS on mobile screens ([#98](https://github.com/Differential/meteor-blog/pull/98))
* Fix 404/notFound templates after upgrade
* Redirect user back to blog index upon logout ([#95](https://github.com/Differential/meteor-blog/pull/95))

### v0.5.5

* Fix bug where post body was not showing up in editor

### v0.5.4

_NOTE: `0.5.4` is only compatible with Meteor `0.9.0` and higher._

* Make compatible with Meteor `0.9.0`

### v0.5.3

* Fix bugs ([#81](https://github.com/Differential/meteor-blog/issues/81), [#78](https://github.com/Differential/meteor-blog/issues/78), [#85](https://github.com/Differential/meteor-blog/issues/85))
* Improve UX where saving tags on posts was unclear
* Add template helper to display latest posts
* Upgrade `medium-editor`, `medium-editor-insert-plugin` libs

### v0.5.2

* Support syntax highlighting ([#76](https://github.com/Differential/meteor-blog/pull/76))
* Add `author` role ([#72](https://github.com/Differential/meteor-blog/issues/72))
* Remove social sharing code and add `shareit` package as a dependency
* Refactor template overriding code to use `UI.dynamic`

### v0.5.0

_NOTE: `0.5.0` is only compatible with Meteor `0.8.2` and higher. Also, the `0.4.0` migration is taken out, so if you are running `0.3.0` of this package, you must upgrade to `0.4.0` first and then upgrade to `0.5.0`._

* Changes to blog editor
  * Allow basic image uploading and storage in _gridFS_ ([#57](https://github.com/Differential/meteor-blog/issues/57))
  * Add HTML mode to blog editor ([#61](https://github.com/Differential/meteor-blog/pull/61))
  * Add tag autocomplete to blog editor ([#62](https://github.com/Differential/meteor-blog/pull/62))
* Add commenting capabilities
  * Allow user to configure a [DISQUS](http://disqus.com) ID to enable DISQUS comments
  * Add [SideComments.js](http://aroc.github.io/side-comments-demo/) (experimental!) ([#60](https://github.com/Differential/meteor-blog/pull/60))
* Allow user to provide custom `notFoundTemplate` ([#65](https://github.com/Differential/meteor-blog/pull/65))

### v0.4.4

* Allow user to override blog excerpt function ([#52](https://github.com/Differential/meteor-blog/pull/52))
* Add minor performance improvements
* Fix minor bugs

### v0.4.3

* Fix bug where LESS files were imported twice ([#48](https://github.com/Differential/meteor-blog/pull/48))
* Add support for `meteor-roles` groups

### v0.4.2

* Fix bugs with pagination ([#44](https://github.com/Differential/meteor-blog/issues/44)), author profile, and T9n.

### v0.4.0

_NOTE: In `0.4.0`, blog contents are stored as HTML, not markdown. There is an automatic migration step if you upgrade, but you may want to backup your blog posts first._

* Complete re-write of blog administrative interface
  * Replace Ace Editor with Medium Editor
  * Replace administrative blog list with fancy table
* Add Google+ authorship link to blog posts

### v0.3.0

_NOTE: `0.3.0` is not guaranteed to work with Meteor `0.7.x` and below. If you are using an older version of Meteor, use Blog `0.2.13`._

* Meteor `0.8.x` compatibility

### v0.2.12

* Add basic tagging of blog posts
* Save on publication data ([#33](https://github.com/Differential/meteor-blog/issues/33))
* Some preparations for Meteor Blaze

### v0.2.11

* Remove `parsleyjs` as a dependency
* Maintain package JS when user overrides view templates ([#28](https://github.com/Differential/meteor-blog/issues/28))
* Add keyboard shortcut to toggle `Preview` mode
* Ensure blog post slugs are unique
* Allow user to override admin templates ([#31](https://github.com/Differential/meteor-blog/issues/31))
* Tweak default CSS for blog list padding and blog post image margins

### v0.2.8

* Unnecessary code cleanup
* Remove hard dependency on moment.js version
* Rename method to minimize conflict
* Fix blog author in model
* Improve RSS

### v0.2.7

* Update to iron-router 0.6.2
* Fixed a few bugs (issues [#16](https://github.com/Differential/meteor-blog/issues/16) and [#17](https://github.com/Differential/meteor-blog/issues/17))
* Add server-side RSS feed

### v0.2.6

_NOTE: If you were using the `excerpt` helper before (`data.excerpt()`), it is now a field (`data.excerpt`)._

* Publish less data to blog index.
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
* Rename some files/folders to match http://github.com/Differential/meteor-boilerplate

### v0.1.0

* Initial release

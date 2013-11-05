---
layout: default
username: BeDifferential
repo: meteor-blog
version: 0.2.0
desc: Gives you an basic, out-of-the-box blog at `/blog`

---
# Meteor Blog

This is a meteorite package that gives you a basic, out-of-the-box blog at
`/blog`.  We wanted something to work with that uses Iron Router, Bootstrap 3,
and didn't require us to run another dyno for a meteor-based blog.

This blog is very much a work in progress. To help decide what gets add next,
vote with your Github issues!

## Roadmap

* <s>Basic markdown editor</s>
* Easily add images
* <s>URL's based on slug from title</s> (but be editable)
* Allow for comments (or at least a comment plugin)
* Ability to create categories/tags
* Widget to embed recent posts on another page
* Customize how posts are displayed on main blog home
* Use Google+ attributions for SEO
* Other SEO best practices
* Pagination
* Multiple roles (admin/author/etc)
* Themes

## Getting Started

```
mrt add blog
```

You will get routes for:

```
/blog
/admin/blog
```

`/admin/blog` requires that `Meteor.user()` return a user.

## Usage

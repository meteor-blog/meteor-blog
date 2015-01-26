## Blog

This Meteor package gives you a basic, out-of-the-box blog at `/blog`. We wanted
a way to add a blog to an existing app without running another dyno or server
for a meteor-based blog.

Example instance: [http://differential.com/blog](http://differential.com/blog)

This blog is very much a work in progress. To help decide what gets add next,
vote with your [Github issues](https://github.com/Differential/meteor-blog/issues)!

### Features

* Medium-style editor
* Slug-based URLs (editable)
* Add images (store in database or upload to S3)
* Support DISQUS comments
* Blog post tags and tag view
* Widget to embed recent posts on another (e.g. home) page
* Customizable templates
* SEO best practices (OpenGraph, Twitter Cards, share buttons, Google+ author attribution)
* Autosave
* Pagination
* Code syntax highlighting
* Multiple roles (admin/author)
* RSS feed

### Roadmap

* Check out the [enhancements tracker](https://github.com/Differential/meteor-blog/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement)

### Quick Start

```bash
$ meteor add ryw:blog
```

You will get routes for:

```
/blog
/admin/blog
```

`/admin/blog` requires that `Meteor.user()` return a user.

# Usage

### Roles

By default, _any_ logged-in user can administer the blog. To ensure that only
select users can edit the blog, the package supports two roles:

* `adminRole` - Can create, and modify or delete any post.
* `authorRole` - Can create, and modify or delete only my own posts.

To enable either or both roles, specify values in the blog config:

```coffee
if Meteor.isServer
  Blog.config
    adminRole: 'blogAdmin'
    authorRole: 'blogAuthor'
```

Then, you need to give blog users that role. Currently, you're on your own to
add these roles somehow:

* Add these directly to admin users in the database (`"roles": ["blogAdmin"]`), or
* Roll your own admin page using the methods provided by [meteor-roles](https://atmosphere.meteor.com/package/roles), or
* Use an accounts admin package like [accounts-admin-ui-bootstrap-3](https://atmosphere.meteor.com/package/accounts-admin-ui-bootstrap-3).

### Comments

**DISQUS**

This package supports [DISQUS](http://disqus.com) comments. Configure your
DISQUS short name in the client and comments will render below all your blog
posts. If you use your own `blogShowTemplate` template, include `{{> disqus this}}` to
display comments.

```coffee
if Meteor.isClient
  Blog.config
    comments:
      disqusShortname: 'myshortname'
```

**SideComments.js**

This package has experimental integration with [SideComments.js](http://aroc.github.io/side-comments-demo/).
Enable side comments in your blog settings. Currently, side comments uses the
Meteor accounts for your Meteor site as comment users, which is probably not
what you want. You can also allow anonymous comments, which lets anyone type in
anything without even a name. Also, probably not what you want.

```coffee
if Meteor.isClient
  Blog.config
    comments:
      useSideComments: true # default is false
      allowAnonymous: true # default is false
```

### Bootstrap Templates

Meteor blog works out-of-the-box with minimal, decent-looking Bootstrap
templates. If you use these default templates, you must add the meteor
`bootstrap-3` package.

```bash
$ meteor add mrt:bootstrap-3
```

### Custom Templates

While the admin templates are opinionated, the front-end is bare markup, ready
to by styled. If the default templates aren't doing it for you, you can override
the default templates with your own by setting configuration variables:

```coffee
if Meteor.isClient
  Blog.config
    blogIndexTemplate: 'myBlogIndexTemplate' # '/blog' route
    blogShowTemplate: 'myShowBlogTemplate'   # '/blog/:slug' route
```

In your templates, you can use these Handlebars helpers provided by the package
to display blog posts with some basic, semantic markup:

* `{{> blogIndex}}` - Renders list of blog posts (`/blog` route)
* `{{> blogShow}}` - Renders single blog post (`/blog/:slug` route)

Example:

```html
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <div>{{> blogIndex}}</div>
</template>
```

If you don't want any of our markup, use the blog data provided in the template
context directly:

* `posts` - Collection of [`minimongoid`](https://github.com/Exygy/minimongoid) blog post objects (`/blog` route)
* `this` - [`minimongoid`](https://github.com/Exygy/minimongoid) blog post object (`/blog/:slug` route)

Example:

```html
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <ul>
    {{#each posts}}
      <li>
        <h2>{{title}}</h2>
        <p>Published on {{publishedAt}}</p>
        <p>Excerpt: {{excerpt}}</p>
      </li>
    {{/each}}
  </ul>
</template>
```

**Custom NotFound**

You can provide a custom `notFoundTemplate` to use when a blog post slug is not
found.

```coffee
if Meteor.isClient
  Blog.config
    blogNotFoundTemplate: 'myNotFoundTemplate'
```

### Blog Post Excerpt

By default, blog summaries or excerpts are generated by taking the 1st paragraph
from the blog post. You can override this function by configuring a custom
`excerptFunction`. For example, if you wanted to create an excerpt from the 1st
sentence:

```coffee
if Meteor.isClient
  Blog.config
    excerptFunction: (body) ->
      body.split('.')[0] + '.'
```

### Images

Adding images to your blog posts works out of the box and saves the images to
gridFS in your Mongo database. You can optionally have these images to an Amazon
S3 bucket that you configure.

To setup S3 for file storage, add the following in `/settings.json` (or any
other location of your choice).

```json
{
  "public": {
    "blog": {
      "useS3": true
    }
  },
  "private": {
    "blog": {
      "s3Config": {
        "bucket": "you-bucket-name",
        "ACL": "public-read",
        "MaxTries": 2,
        "accessKeyId": "XXXXXXXXXXXXX",
        "secretAccessKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### Pagination

By default, blog posts are paged in 20 at a time.  You can modify this value in
settings. Set to `null` to turn off paging entirely.

```coffee
if Meteor.isClient
  Blog.config
    pageSize: 10
```

The default `blogIndexTemplate` template displays a `Load More` button. If you
use your own template, include the `{{blogPager}}` helper to display the button.

### Code Highlighting

If you fancy a coding blog, the blog package supports syntax highlighting using
[highlight.js](http://highlightjs.org/). If enabled, any content within `<pre>`
tags will get modified for syntax highlighting. You can specify any
[`highlight.js` style file](https://github.com/isagalaev/highlight.js/tree/master/src/styles).
Example config:

```coffee
if Meteor.isClient
  Blog.config
    syntaxHighlighting: true # default is false
    syntaxHighlightingTheme: 'atelier-dune.dark' # default is 'github'
```

### Social Sharing

This package depends on the [`shareit` package](https://atmospherejs.com/package/shareit)
for powering social sharing.  If you use your own `blogShowTemplate` template,
include `{{> shareit}}` to display share buttons.

### Recent Posts Helper

You can include a basic snippet of HTML displaying recent blog posts (e.g. on
your home page). Insert the inclusion helper where you want the recent posts to
appear.

```html
{{> blogLatest}}
```

Or you can specify the # of posts to show:

```html
{{> blogLatest num=5}}
```

There are classes in the template for styling.

### RSS

An RSS feed is automatically generated at `/rss/posts`. To set the title and
description in the feed, configure RSS:

```coffee
if Meteor.isServer
  Blog.config
    rss:
      title: 'My blog title'
      description: 'My blog description'
```

Add a head tag somewhere in your `.html` files so your RSS feed can be discovered:

```html
<head>
  <link rel="alternate" type="application/rss+xml" title="My blog title" href="/rss/posts">
</head>
```

---
layout: default
username: Differential
repo: meteor-blog
version: 0.5.0
desc: Gives you an basic, out-of-the-box blog at `/blog`

---
# Blog

This Meteor package gives you a basic, out-of-the-box blog at `/blog`. We wanted
a way to add a blog to an existing app without running another dyno or server
for a meteor-based blog.

This blog is very much a work in progress. To help decide what gets add next,
vote with your [Github issues](https://github.com/Differential/meteor-blog/issues)!

### Roadmap

* <s>Basic markdown editor</s>
* <s>URL's based on slug from title (but be editable)</s>
* <s>Easily add images</s> to S3 or Cloud Files
* <s>Allow for comments (or at least a comment plugin)</s>
* <s>Ability to create categories/tags</s>
* Widget to embed recent posts on another page
* <s>Customize how posts are displayed on main blog home</s>
* <s>Use Google+ attributions for SEO</s>
* Other SEO best practices (<s> OpenGraph, Twitter Cards, share buttons</s>)
* <s>Pagination</s>
* Multiple roles (<s>admin</s>/author/etc)
* <s>RSS</s>

### Quick Start

```
mrt add blog
```

You will get routes for:

```
/blog
/admin/blog
```

`/admin/blog` requires that `Meteor.user()` return a user.

# Usage

### Roles

By default, any logged-in user can administer the blog. To ensure that only
select users can edit the blog, specify an `adminRole` in the blog config:

{% highlight coffeescript %}
if Meteor.isServer
  Blog.config
    adminRole: 'blogAdmin'
{% endhighlight %}

Then, you need to give blog admin users that role. Currently, you're on your own
to add these roles somehow:

* Add these directly to admin users in the database (`"roles": ["blogAdmin"]`), or
* Roll your own admin page using the methods provided by [meteor-roles](https://atmosphere.meteor.com/package/roles), or
* Use an accounts admin package like [accounts-admin-ui-bootstrap-3](https://atmosphere.meteor.com/package/accounts-admin-ui-bootstrap-3).

### Fast Render

If your app uses [fast-render](https://github.com/arunoda/meteor-fast-render),
the blog pages will render using fast-render automatically.

### Comments

**DISQUS**

This package supports [DISQUS](http://disqus.com) comments. Configure your
DISQUS short name in the client and comments will render below all your blog
posts.

{% highlight coffeescript %}
if Meteor.isClient
  Blog.config
    disqusShortname: 'myshortname'
{% endhighlight %}

**SideComments.js**

This package has experimental integration with [SideComments.js](http://aroc.github.io/side-comments-demo/).
Enable side comments in your blog settings. Currently, side comments uses the
Meteor accounts for your Meteor site as comment users, which is probably not
what you want. You can also allow anonymous comments, which lets anyone type in
anything without even a name. Also, probably not what you want.

{% highlight coffeescript %}
if Meteor.isClient
  Blog.config
    useSideComments: true # default is 'false'
    allowAnonymous: true # default is 'false'
{% endhighlight %}

### Bootstrap Templates

Meteor blog works out-of-the-box with minimal, decent-looking Bootstrap
templates. If you use these default templates, you must add the meteor
`bootstrap-3` package.

```
mrt add bootstrap-3
```

### Custom Templates

While the admin templates are opinionated, the front-end is bare markup, ready
to by styled. If the default templates aren't doing it for you, you can override
the default templates with your own by setting configuration variables:

{% highlight coffeescript %}
if Meteor.isClient
  Blog.config
    blogIndexTemplate: 'myBlogIndexTemplate' # '/blog' route
    blogShowTemplate: 'myShowBlogTemplate'   # '/blog/:slug' route
{% endhighlight %}

In your templates, you can use these Handlebars helpers provided by the package
to display blog posts with some basic, semantic markup:

{% assign bi = '{{> blogIndex}}' %}
{% assign bs = '{{> blogShow}}' %}
* `{{ bi }}` - Renders list of blog posts (`/blog` route)
* `{{ bs }}` - Renders single blog post (`/blog/:slug` route)

Example:

{% highlight html %}
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <div>{{ bi }}</div>
</template>
{% endhighlight %}

If you don't want any of our markup, use the blog data provided in the template
context directly:

* `posts` - Collection of [`minimongoid`](https://github.com/Exygy/minimongoid) blog post objects (`/blog` route)
* `this` - [`minimongoid`](https://github.com/Exygy/minimongoid) blog post object (`/blog/:slug` route)

Example:

{% assign ep = '{{#each posts}}' %}
{% assign ee = '{{/each}}' %}
{% assign t = '{{title}}' %}
{% assign p = '{{publishedAt}}' %}
{% assign ex = '{{excerpt}}' %}
{% highlight html %}
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <ul>
    {{ep}}
      <li>
        <h2>{{t}}</h2>
        <p>Published on {{p}}</p>
        <p>Excerpt: {{ex}}</p>
      </li>
    {{ee}}
  </ul>
</template>
{% endhighlight %}

### Blog Post Excerpt

By default, blog summaries or excerpts are generated by taking the 1st paragraph
from the blog post. You can override this function by configuring a custom
`excerptFunction`. For example, if you wanted to create an excerpt from the 1st
sentence:

{% highlight coffeescript %}
if Meteor.isClient
  Blog.config
    excerptFunction: (body) ->
      body.split('.')[0] + '.'
{% endhighlight %}

### Pagination

By default, blog posts are paged in 20 at a time.  You can modify this value in
settings. Set to `null` to turn off paging entirely.

{% highlight coffeescript %}
if Meteor.isClient
  Blog.config
    pageSize: 10
{% endhighlight %}

{% assign bp = '{{blogPager}}' %}
The default `blogIndexTemplate` template displays a `Load More` button. If you
use your own template, include the `{{ bp }}` helper to display the button.

### RSS

An RSS feed is automatically generated at `/rss/posts`. To set the title and
description in the feed, configure RSS:

{% highlight coffeescript %}
if Meteor.isServer
  Blog.config
    title: 'My blog title'
    description: 'My blog description'
{% endhighlight %}

Add a head tag somewhere in your `.html` files so your RSS feed can be discovered:

{% highlight html %}
<head>
  <link rel="alternate" type="application/rss+xml" title="My blog title" href="/rss/posts">
</head>
{% endhighlight %}

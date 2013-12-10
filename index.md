---
layout: default
username: BeDifferential
repo: meteor-blog
version: 0.2.3
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
* <s>URL's based on slug from title</s> (but be editable)
* Easily add images
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

Meteor blog should work out-of-the-box (hopefully) with some decent looking
templates. If you use the default templates, you must add the meteor
`bootstrap-3` package.

```
mrt add bootstrap-3
```

#### Customisation

If the default templates aren't doing it for you, you can override the default
templates with your own by setting configuration variables:

{% highlight coffeescript %}
Meteor.startup ->
  Blog.config
    blogIndexTemplate: 'myBlogIndexTemplate' # '/blog' route
    blogShowTemplate: 'myShowBlogTemplate'   # '/blog/:slug' route
{% endhighlight %}

In your templates, you can use these Handlebars helpers provided by the package
to display blog posts with some basic markup:

{% assign bi = '{{blogIndex}}' %}
{% assign bs = '{{blogShow}}' %}
* `{{ bi }}` - Renders list of blog posts (`/blog` route)
* `{{ bs }}` - Renders single blog post (`/blog/:slug` route)

Example:

{% highlight html %}
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <div>{{ bi }}</div>
</template>
{% endhighlight %}

For finer-grained control, the blog routes provides the data in the template
context:

* `posts` - Collection of [`minimongoid`](https://github.com/Exygy/minimongoid) blog post objects (`/blog` route)
* `this` - [`minimongoid`](https://github.com/Exygy/minimongoid) blog post object (`/blog/:slug` route)

Example:

{% assign ep = '{{#each posts}}' %}
{% assign ee = '{{/each}}' %}
{% assign t = '{{title}}' %}
{% assign p = '{{publishedAt}}' %}
{% assign b = '{{body}}' %}
{% assign h = '{{{html}}}' %}
{% highlight html %}
<template name="myBlogIndexTemplate">
  <h1>Welcome to my Blog</h1>
  <ul>
    {{ep}}
      <li>
        <h2>{{t}}</h2>
        <p>Published on {{p}}</p>
        <p>Markdown: {{b}}</p>
        <p>HTML: {{h}}</p>
      </li>
    {{ee}}
  </ul>
</template>
{% endhighlight %}

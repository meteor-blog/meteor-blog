Meteor.methods

  serveRSS: () ->
    RSS = Npm.require('rss')
    host = _.trim Meteor.absoluteUrl(), '/'

    feed = new RSS
      title: Blog.settings.rss.title
      description: Blog.settings.rss.description
      feed_url: host + '/rss/posts'
      site_url: host
      image_url: host + '/favicon.ico'

    posts = Post.where
      published: true
    ,
      sort:
        publishedAt: -1
      limit: 20

    posts.forEach (post) ->
      feed.item
       title: post.title
       description: post.excerpt
       author: post.authorName()
       date: post.publishedAt
       url: "#{host}/blog/#{post.slug}"
       guid: post._id

    return feed.xml()

##############################################################################
# Server-side config
#

Blog =
  settings:
    adminRole: null
    rss:
      title: ''
      description: ''

  config: (appConfig) ->
    @settings = _.extend(@settings, appConfig)

@Blog = Blog

################################################################################
# Bootstrap Code
#

Meteor.startup ->

  ##############################################################################
  # Migrations and such
  #

  Post._collection._ensureIndex 'slug': 1

  # Create 'excerpt' field if none
  if Post.where({ excerpt: { $exists: 0 }}).length
    arr = Post.where({ excerpt: { $exists: 0 }})
    i = 0
    while i < arr.length
      obj = arr[i++]
      obj.update({ excerpt: Post.excerpt(obj.body) })

  ##############################################################################
  # Server-side methods
  #

  Meteor.methods
    isBlogAuthorized: () ->
      if not Meteor.user()
        return false

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return false

      true

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

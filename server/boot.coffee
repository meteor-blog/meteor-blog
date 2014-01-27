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
  # Server-side config
  #

  Blog =
    settings:
      adminRole: null
      title: ''
      description: ''
      feedPath: 'rss/posts'
      imagePath: 'img/favicon.png'

    config: (appConfig) ->
      @settings = _.extend(@settings, appConfig)

  @Blog = Blog

  ##############################################################################
  # Server-side methods
  #
  Meteor.methods
    isAuthorized: () ->
      if not Meteor.user()
        return false

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return false

      true

    serveRSS: () ->
      RSS = Npm.require('rss')
      feed = new RSS
        title: Blog.settings.title
        description: Blog.settings.description
        feed_url: Meteor.absoluteUrl()+Blog.settings.feedPath
        site_url: Meteor.absoluteUrl()
        image_url: Meteor.absoluteUrl()+Blog.settings.imagePath

      Post.find({published: true}, { fields: { published: 1 }, sort: { publishedAt: -1 } }, { limit: 20 }).forEach (post)->
        postObj = Post.find(post._id)

        feed.item
         title: post.title
         description: post.excerpt
         author: postObj.authorName()
         date: post.publishedAt
         url: Meteor.absoluteUrl()+'blog/'+post.slug
         guid: post._id

      return feed.xml()

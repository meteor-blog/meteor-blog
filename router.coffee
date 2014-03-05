Router.map ->

  #
  # RSS Feed
  #

  if Meteor.isServer
    @route 'rss',
      where: 'server'
      path: '/rss/posts'
      action: ->
        @response.write Meteor.call 'serveRSS'
        @response.end()

  #
  # Blog Index
  #

  @route 'blogIndex',
    path: '/blog'
    controller: 'BasicController'
    before: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      if not Session.get('postLimit') and Blog.settings.pageSize
        Session.set 'postLimit', Blog.settings.pageSize
      @subscribe('posts', Session.get('postLimit')).wait()

    waitOn: ->
      Meteor.subscribe 'authors'

    fastRender: true

    data: ->
      if @ready()
        posts: Post.where
          published: true
        ,
          sort:
            publishedAt: -1

  #
  # Blog Tag
  #

  @route 'blogTagged',
    path: '/blog-tag/:tag'
    controller: 'BasicController'
    before: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('taggedPosts', @params.tag).wait()

    waitOn: ->
      Meteor.subscribe 'authors'

    fastRender: true

    data: ->
      if @ready()
        posts: Post.where
          published: true
          tags: @params.tag
        ,
          sort:
            publishedAt: -1


  #
  # Show Blog
  #

  @route 'blogShow',

    path: '/blog/:slug'

    controller: 'BasicController'
    notFoundTemplate: 'blogNotFound'

    before: ->
      if Blog.settings.blogShowTemplate
        @template = Blog.settings.blogShowTemplate

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('singlePost', @params.slug).wait()

    waitOn: ->
      Meteor.subscribe 'authors'

    fastRender: true

    data: ->
      if @ready()
        Post.first slug: @params.slug

  #
  # Blog Admin Index
  #

  @route 'blogAdmin',

    path: '/admin/blog'
    controller: 'BasicController'

    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]

    before: ->
      if Meteor.loggingIn()
        return @stop()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

  #
  # New Blog
  #

  @route 'blogAdminNew',
    path: '/admin/blog/new'
    controller: 'BasicController'

    before: ->
      if Meteor.loggingIn()
        return @stop()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

  #
  # Edit Blog
  #

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:slug'
    controller: 'BasicController'

    waitOn: ->
      Meteor.subscribe 'authors'

    data: ->
      if @ready()
        Post.first slug: @params.slug

    before: ->
      if Meteor.loggingIn()
        return @stop()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('singlePost', @params.slug).wait()

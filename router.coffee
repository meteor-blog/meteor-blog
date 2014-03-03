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
  # Show Blog
  #

  @route 'blogShow',

    path: '/blog/:slug'

    notFoundTemplate: 'blogNotFound'

    before: ->
      if Blog.settings.blogShowTemplate
        @template = Blog.settings.blogShowTemplate

        # If the user has a custom template, and not using the helper, then
        # maintain the package Javascript so that OpenGraph tags and share
        # buttons still work.
        pkgFunc = Template.blogShowBody.rendered
        userFunc = Template[@template].rendered

        if userFunc
          Template[@template].rendered = ->
            pkgFunc.call(@)
            userFunc.call(@)
        else
          Template[@template].rendered = pkgFunc

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

    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]

    before: ->

      if Blog.settings.blogAdminTemplate
        @template = Blog.settings.blogAdminTemplate

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

    before: ->

      if Blog.settings.blogAdminNewTemplate
        @template = Blog.settings.blogAdminNewTemplate

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

    waitOn: ->
      Meteor.subscribe 'authors'

    data: ->
      if @ready()
        Post.first slug: @params.slug

    before: ->
      if Blog.settings.blogAdminEditTemplate
        @template = Blog.settings.blogAdminEditTemplate

      if Meteor.loggingIn()
        return @stop()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('singlePost', @params.slug).wait()

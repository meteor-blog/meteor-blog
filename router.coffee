Router.onBeforeAction 'loading'
Router.onBeforeAction 'dataNotFound'

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

    onRun: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

      if not Session.get('postLimit') and Blog.settings.pageSize
        Session.set 'postLimit', Blog.settings.pageSize

    waitOn: -> [
      Meteor.subscribe 'posts', Session.get('postLimit')
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      posts: Post.where
        published: true
      ,
        sort:
          publishedAt: -1

  #
  # Blog Tag
  #

  @route 'blogTagged',
    path: '/blog/tag/:tag'

    onRun: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

    waitOn: -> [
      Meteor.subscribe 'taggedPosts', @params.tag
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
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

    notFoundTemplate: 'blogNotFound'

    onRun: ->
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

    waitOn: -> [
      Meteor.subscribe 'singlePostBySlug', @params.slug
      Meteor.subscribe 'authors'
    ]

    data: ->
      Post.first slug: @params.slug

  #
  # Blog Admin Index
  #

  @route 'blogAdmin',
    path: '/admin/blog'

    onRun: ->
      if Blog.settings.blogAdminTemplate
        @template = Blog.settings.blogAdminTemplate

    onBeforeAction: (pause) ->
      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]

    data: ->
      true

  #
  # New/Edit Blog
  #

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:id'

    onRun: ->
      if Blog.settings.blogAdminEditTemplate
        @template = Blog.settings.blogAdminEditTemplate

    onBeforeAction: (pause) ->
      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')
        else
          Session.set 'postId', @params.id

    waitOn: -> [
      Meteor.subscribe 'singlePostById', @params.id
      Meteor.subscribe 'authors'
    ]

    data: ->
      true

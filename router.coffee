class @BlogController extends RouteController
  action: ->
    if @ready()
      @render()
    else if Template['loading']
      @render 'loading'

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
    controller: 'BlogController'

    onBeforeAction: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

    waitOn: -> [
      Meteor.subscribe 'posts', Blog.settings.pageSize
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
    controller: 'BlogController'

    onBeforeAction: ->
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
    controller: 'BlogController'
    notFoundTemplate: 'blogNotFound'

    onBeforeAction: ->
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
    controller: 'BlogController'

    onBeforeAction: (pause) ->

      if Blog.settings.blogAdminTemplate
        @template = Blog.settings.blogAdminTemplate

      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]

  #
  # New/Edit Blog
  #

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:id'
    controller: 'BlogController'

    onBeforeAction: (pause) ->
      if Blog.settings.blogAdminEditTemplate
        @template = Blog.settings.blogAdminEditTemplate

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

if Meteor.isClient
  Router.onBeforeAction 'loading'
  Router.onBeforeAction (pause) ->
    if @_dataValue is null or typeof @_dataValue is 'undefined'
      return

    Router.hooks.dataNotFound.call @, pause

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
    template: 'dynamic'

    onRun: ->
      if not Session.get('postLimit') and Blog.settings.pageSize
        Session.set 'postLimit', Blog.settings.pageSize

    waitOn: -> [
      Meteor.subscribe 'posts', Session.get('postLimit')
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      posts: Post.where {},
        sort: publishedAt: -1

  #
  # Blog Tag
  #

  @route 'blogTagged',
    path: '/blog/tag/:tag'
    template: 'dynamic'

    waitOn: -> [
      Meteor.subscribe 'taggedPosts', @params.tag
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      posts: Post.where
        tags: @params.tag
      ,
        sort: publishedAt: -1

  #
  # Show Blog
  #

  @route 'blogShow',
    path: '/blog/:slug'
    template: 'dynamic'
    notFoundTemplate: 'blogNotFound'

    onRun: ->
      Session.set('slug', @params.slug)

    onBeforeAction: ->
      if Blog.settings.blogNotFoundTemplate
        @notFoundTemplate = Blog.settings.blogNotFoundTemplate

      if Blog.settings.blogShowTemplate
        tpl = Blog.settings.blogShowTemplate

        # If the user has a custom template, and not using the helper, then
        # maintain the package Javascript.
        pkgFunc = Template.blogShowBody.rendered
        userFunc = Template[tpl].rendered

        if userFunc
          Template[tpl].rendered = ->
            pkgFunc.call(@)
            userFunc.call(@)
        else
          Template[tpl].rendered = pkgFunc

    action: ->
      @render() if @ready()

    waitOn: -> [
      Meteor.subscribe 'singlePostBySlug', @params.slug
      Meteor.subscribe 'commentsBySlug', @params.slug
      Meteor.subscribe 'authors'
    ]

    data: ->
      Post.first slug: @params.slug

  #
  # Blog Admin Index
  #

  @route 'blogAdmin',
    path: '/admin/blog'
    template: 'dynamic'

    onBeforeAction: (pause) ->
      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

    waitOn: ->
      [ Meteor.subscribe 'postForAdmin'
        Meteor.subscribe 'authors' ]

    data: ->
      true

  #
  # New/Edit Blog
  #

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:id'
    template: 'dynamic'

    onBeforeAction: (pause) ->
      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', @params.id, (err, authorized) =>
        if not authorized
          return @redirect('/blog')

    action: ->
      @render() if @ready()

    onRun: ->
      Session.set 'postId', @params.id
      Session.set('editorTemplate', 'visualEditor')
      Session.set('currentPost', Post.first(@params.id))

    waitOn: -> [
      Meteor.subscribe 'singlePostById', @params.id
      Meteor.subscribe 'authors'
      Meteor.subscribe 'postTags'
    ]

    data: ->
      true

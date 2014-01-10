Router.map ->

  @route 'blogIndex',
    path: '/blog'
    before: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]
    fastRender: true
    data: ->
      posts: Post.where { published: true }, { sort: { publishedAt: -1 }}

  @route 'blogShow',
    path: '/blog/:slug'
    notFoundTemplate: 'blogNotFound'
    before: ->
      if Blog.settings.blogShowTemplate
        @template = Blog.settings.blogShowTemplate
      Session.set 'postSlug', @params.slug

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('singlePost', @params.slug).wait()
    waitOn: ->
      Meteor.subscribe 'authors'
    fastRender: true
    data: ->
      if @ready()
        Post.first slug: @params.slug

  @route 'blogAdmin',
    path: '/admin/blog'
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return @redirect('/blog')

  @route 'blogAdminNew',
    path: '/admin/blog/new'
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return @redirect('/blog')

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:slug'
    waitOn: ->

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      Meteor.subscribe 'authors'
    data: ->
      if @ready()
        Post.first slug: @params.slug
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return @redirect('/blog')

      Session.set 'postSlug', @params.slug
      @subscribe('singlePost', @params.slug).wait()

Router.map ->

  @route 'blogIndex',
    path: '/blog'
    before: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'users' ]
    data: ->
      posts: Post.where published: true

  @route 'blogShow',
    path: '/blog/:slug'
    notFoundTemplate: 'blogNotFound'
    before: ->
      if Blog.settings.blogShowTemplate
        @template = Blog.settings.blogShowTemplate
      Session.set 'postSlug', @params.slug
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'users' ]
    data: ->
      Post.first slug: @params.slug

  @route 'blogAdmin',
    path: '/admin/blog'
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'users' ]
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

  @route 'blogAdminNew',
    path: '/admin/blog/new'
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:slug'
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'users' ]
    data: ->
      Post.first slug: @params.slug
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

      Session.set 'postSlug', @params.slug

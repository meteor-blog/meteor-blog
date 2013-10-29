Router.map ->

  @route 'blogIndex',
    path: '/blog'
    waitOn: ->
      Meteor.subscribe 'posts'
    data: ->
      posts: Post.where published: true

  @route 'blogShow',
    path: '/blog/:slug'
    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'users' ]
    data: ->
      Post.first slug: @params.slug
    before: ->
      Session.set 'postSlug', @params.slug

  @route 'blogAdmin',
    path: '/admin/blog'
    waitOn: ->
      Meteor.subscribe 'posts'
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
      Meteor.subscribe 'posts'
    data: ->
      Post.first slug: @params.slug
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

      Session.set 'postSlug', @params.slug

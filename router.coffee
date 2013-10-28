Router.map ->

  @route 'blogIndex',
    path: '/blog'

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

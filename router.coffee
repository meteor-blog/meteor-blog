Router.map ->

  @route 'blogIndex',
    path: '/blog'

  @route 'blogAdmin',
    path: '/admin/blog'
    waitOn: ->
      Meteor.subscribe 'posts'
    data: ->
      posts: Post.all()
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

  @route 'blogAdminNew',
    path: '/admin/blog/edit/:id'
    before: ->
      if Meteor.loggingIn()
        return @stop()

      if not Meteor.user()
        return @redirect('/blog')

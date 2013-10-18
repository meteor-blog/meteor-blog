Router.map ->

  @route 'blogIndex',
    path: '/blog'

  @route 'blogAdmin',
    path: '/admin/blog'
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

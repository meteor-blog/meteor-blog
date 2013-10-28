Template.blogAdminList.helpers

  posts: ->
    results = Post.all()

    if _.size Session.get 'filters'
      results = _(results).where Session.get('filters')

    results

  author: ->
    #user = @user() # doesn't work?
    user = User.first @userId

    if user.profile.firstName and user.profile.lastName
      return "#{user.profile.firstName} #{user.profile.lastName}"
    else if user.profile.twitter
      return user.profile.twitter
    else if user.username
      return user.username
    else if user.emails and user.emails[0]
      return user.emails[0].address

    'Mystery blogger'

  formatDate: (date) ->
    moment(new Date(date)).format "MMM Do, YYYY"

Template.blogAdmin.events

  'change .for-filtering': (e) ->
    e.preventDefault()

    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()

    Session.set 'filters', filters

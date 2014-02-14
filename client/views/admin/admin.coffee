Template.blogAdminList.helpers

  posts: ->
    results = Post.all { sort: { updatedAt: -1 }}

    if _.size Session.get 'filters'
      results = _(results).where Session.get('filters')

    results

Template.blogAdmin.events

  'change .for-filtering': (e) ->
    e.preventDefault()

    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()

    Session.set 'filters', filters

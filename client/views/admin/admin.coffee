Template.blogAdmin.helpers

  posts: ->
    results = Post.all { sort: { updatedAt: -1 }}

    if _.size Session.get 'filters'
      results = _(results).where Session.get('filters')

    results

Template.blogAdmin.events

  'click .for-new-blog': (e, tpl) ->
    e.preventDefault()

    id = new Meteor.Collection.ObjectID()._str
    Router.go 'blogAdminEdit', id: id

  'change .for-filtering': (e) ->
    e.preventDefault()

    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()

    Session.set 'filters', filters

Template.blogAdminRow.events

  'click .for-publish': (e, tpl) ->
    e.preventDefault()
    @update
      published: true
      publishedAt: new Date()

  'click .for-unpublish': (e, tpl) ->
    e.preventDefault()
    @update
      published: false
      publishedAt: null

  'click .delete': (e, tpl) ->
    e.preventDefault()

    if confirm('Are you sure?')
      $(e.currentTarget).parents('.blogAdminRow').fadeOut =>
        @destroy()

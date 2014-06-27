Template.blogAdmin.rendered = ->
  $(@find '.reactive-table').addClass 'table-bordered'
  $(@find '.updatedAt').click().click()

Template.blogAdmin.helpers

  posts: ->
    # Call toArray() because minimongoid does not return a true array, and
    # reactive-table expects a true array (or collection)
    results = Post.all(sort: updatedAt: -1).toArray()

    if _.size Session.get 'filters'
      results = _(results).where Session.get('filters')

    results

  table: ->
    rowsPerPage: 20
    showFilter: false
    useFontAwesome: true
    fields: [
      { key: 'title', label: 'Title', tmpl: Template.blogAdminTitleColumn }
      { key: 'userId', label: 'Author', tmpl: Template.blogAdminAuthorColumn }
      { key: 'updatedAt', label: 'Updated At', tmpl: Template.blogAdminUpdatedColumn }
      { key: 'publishedAt', label: 'Published At', tmpl: Template.blogAdminPublishedColumn }
      { key: 'published', label: 'Status', tmpl: Template.blogAdminStatusColumn }
      { key: 'id', label: 'Edit', tmpl: Template.blogAdminEditColumn }
      { key: 'id', label: 'Delete', tmpl: Template.blogAdminDeleteColumn }
    ]

Template.blogAdmin.events

  'click .for-new-blog': (e, tpl) ->
    e.preventDefault()

    Router.go 'blogAdminEdit', id: Random.id()

  'change .for-filtering': (e) ->
    e.preventDefault()

    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()

    Session.set 'filters', filters

Template.blogAdminStatusColumn.events

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

Template.blogAdminDeleteColumn.events

  'click .delete': (e, tpl) ->
    e.preventDefault()

    if confirm('Are you sure?')
      $(e.currentTarget).parents('tr').fadeOut =>
        @destroy()

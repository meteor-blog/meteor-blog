Template.blogAdmin.rendered = ->
  $(@find '.reactive-table').addClass 'table-bordered'

Template.blogAdmin.helpers

  posts: ->
    # Call toArray() because minimongoid does not return a true array, and
    # reactive-table expects a true array (or collection)
    results = Blog.Post.all(sort: updatedAt: -1).toArray()

    if _.size Session.get 'filters'
      results = _(results).where Session.get('filters')

    results

  table: ->
    rowsPerPage: 20
    showFilter: false
    showNavigation: 'auto'
    useFontAwesome: true
    fields: [
      { key: 'title', label: 'Title', tmpl: Template.blogAdminTitleColumn }
      { key: 'userId', label: 'Author', tmpl: Template.blogAdminAuthorColumn }
      { key: 'updatedAt', label: 'Updated At', tmpl: Template.blogAdminUpdatedColumn, sort: 'descending', sortByValue: true }
      { key: 'publishedAt', label: 'Published At', tmpl: Template.blogAdminPublishedColumn, sortByValue: true }
      { key: 'visibleTo', label: 'Visible To', tmpl: Template.blogAdminVisibleColumn }
      { key: 'id', label: 'Edit', tmpl: Template.blogAdminEditColumn }
      { key: 'id', label: 'Delete', tmpl: Template.blogAdminDeleteColumn }
    ]

Template.blogAdmin.events

  'click [data-action=new-blog]': (e, tpl) ->
    e.preventDefault()

    Router.go 'blogAdminEdit', id: Random.id()

  'change [data-action=filtering]': (e) ->
    e.preventDefault()

    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()

    Session.set 'filters', filters

Template.blogAdminVisibleColumn.helpers

  isSelected: (mode) ->
    mode is @mode

Template.blogAdminVisibleColumn.events

  'change [data-action=visibility]': (e, tpl) ->
    e.preventDefault()
    mode = e.currentTarget.value
    publishedAt = if mode is 'draft' then null else new Date()
    @update
      mode: mode
      publishedAt: publishedAt

Template.blogAdminDeleteColumn.events

  'click [data-action=delete]': (e, tpl) ->
    e.preventDefault()

    if confirm('Are you sure?')
      $(e.currentTarget).parents('tr').fadeOut =>
        @destroy()

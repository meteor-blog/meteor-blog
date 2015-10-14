Template.blogAdmin.onCreated ->
  postsSub = @subscribe 'blog.postForAdmin'
  authorsSub = @subscribe 'blog.authors'

  @subsReady = new ReactiveVar false
  @autorun =>
    if postsSub.ready() and authorsSub.ready() and !Meteor.loggingIn()
      @subsReady.set true

  @autorun ->
    Blog.Router.go 'blogIndex' if not Meteor.userId()

Template.blogAdmin.onRendered ->
  Meteor.call 'isBlogAuthorized', (err, authorized) =>
    if not authorized
      return Blog.Router.go('/blog')

Template.blogAdmin.helpers
  subsReady: -> Template.instance().subsReady.get()
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
    'class': 'table table-striped table-hover col-sm-12 table-bordered'
    fields: [
      { key: 'title', label: Blog.settings.language.title, tmpl: Template.blogAdminTitleColumn }
      { key: 'userId', label: Blog.settings.language.author, tmpl: Template.blogAdminAuthorColumn }
      { key: 'updatedAt', label: Blog.settings.language.updatedAt, tmpl: Template.blogAdminUpdatedColumn, sort: 'descending', sortByValue: true }
      { key: 'publishedAt', label: Blog.settings.language.publishedAt, tmpl: Template.blogAdminPublishedColumn, sortByValue: true }
      { key: 'visibleTo', label: Blog.settings.language.visibleTo, tmpl: Template.blogAdminVisibleColumn }
      { key: 'id', label: Blog.settings.language.edit, tmpl: Template.blogAdminEditColumn }
      { key: 'id', label: Blog.settings.language.delete, tmpl: Template.blogAdminDeleteColumn }
    ]

Template.blogAdmin.events
  'click [data-action=new-blog]': (e, tpl) ->
    e.preventDefault()
    Blog.Router.go 'blogAdminEdit', id: 'new'

  'change [data-action=filtering]': (e) ->
    e.preventDefault()
    filters = {}
    if $(e.currentTarget).val() == 'mine'
      filters.userId = Meteor.userId()
    Session.set 'filters', filters


# ------------------------------------------------------------------------------
# TABLE COLUMNS


Template.blogAdminVisibleColumn.helpers
  isSelected: (mode) -> mode is @mode

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

    console.log Blog.settings

    if confirm(Blog.settings.language.areYouSure)
      $(e.currentTarget).parents('tr').fadeOut =>
        @destroy()

Template.blogAdminEdit.rendered = ->
  $('.post-form').parsley()

  @editor = new EpicEditor
    container: 'editor',
    basePath: '/packages/blog/public/epiceditor'
    autogrow: true
    focusOnLoad: true
    clientSideStorage: false
    button:
      preview: false
    theme:
      editor: '/themes/editor/epic-grey.css'
      preview: '/themes/preview/github.css'

  @editor.load()
  post = Post.first slug: Session.get('postSlug')
  @editor.importFile post.slug, post.body

  $('.make-switch').bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      return @editor.preview()

    @editor.edit()

flash = (status) ->
  setTimeout ->
    $('.status').hide().html(status).fadeIn 'slow', ->
      setTimeout ->
        $('.status').fadeOut 'slow'
      , 2500
  , 100

Template.blogAdminEdit.events

  'click .for-deleting': (e, tpl) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @destroy()
      Router.go 'blogAdmin'

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    attrs =
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      updatedAt: new Date()

    if @published
      status = 'Unpublished'
      $(e.currentTarget).html '<i class="icon-globe"> Publish'
      attrs.published = false
      attrs.publishedAt = null

    else
      status = 'Published'
      $(e.currentTarget).html '<i class="icon-globe"> Unpublish'
      attrs.published = true
      attrs.publishedAt = new Date()

    @update attrs
    flash status

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    @update
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      updatedAt: new Date()

    flash 'Saved'

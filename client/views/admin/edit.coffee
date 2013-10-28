Template.blogAdminEdit.rendered = ->
  $('.post-form').parsley()

  @editor = new EpicEditor
    container: 'editor',
    basePath: '/packages/blog/public/epiceditor'
    autogrow: true
    focusOnLoad: true
    #button: false
    theme:
      editor: '/themes/editor/epic-grey.css'
      preview: '/themes/preview/github.css'

  post = Post.first slug: Session.get('postSlug')
  @editor.load()
  @editor.importFile 'blog-post', post.body

  $('.make-switch').bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      return @editor.preview()

    @editor.edit()

Template.blogAdminEdit.events

  'click .for-deleting': (e, tpl) ->
    e.preventDefault();
    if confirm 'Are you sure?'
      @destroy()
      Router.go 'blogAdmin'

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    if @published
      status = 'Unpublished'
      $(e.currentTarget).html '<i class="icon-globe"> Publish'
      @update
        title: $('[name=title]').val()
        body: tpl.editor.exportFile()
        published: false
        publishedAt: null
        updatedAt: new Date()

    else
      status = 'Published'
      $(e.currentTarget).html '<i class="icon-globe"> Unpublish'
      @update
        title: $('[name=title]').val()
        body: tpl.editor.exportFile()
        published: true
        publishedAt: new Date()
        updatedAt: new Date()

    setTimeout ->
      $('.status').hide().html(status).fadeIn 'slow', ->
        setTimeout ->
          $('.status').fadeOut 'slow'
        , 2500
    , 100

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    @update
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      updatedAt: new Date()

    setTimeout ->
      $('.status').hide().html('Saved').fadeIn 'slow', ->
        setTimeout ->
          $('.status').fadeOut 'slow'
        , 2500
    , 100

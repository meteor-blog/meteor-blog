Template.blogAdminNew.rendered = ->
  $('.post-form').parsley()

  @editor = new EpicEditor
    container: 'editor',
    basePath: '/packages/blog/public/epiceditor'
    autogrow: true
    focusOnLoad: false
    clientSideStorage: false
    button:
      preview: false
    theme:
      editor: '/themes/editor/epic-grey.css'
      preview: '/themes/preview/github.css'

  @editor.load()
  $('[name=title]').focus().val ''

  $('.make-switch').bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      return @editor.preview()

    @editor.edit()

flash = (status, post) ->
  setTimeout ->
    $('.status').hide().html(status).fadeIn 'slow', ->
      setTimeout ->
        Router.go "blogAdminEdit", slug: post.slug
      , 2500
  , 100

Template.blogAdminNew.events

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    post = Post.create
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      published: true
      createdAt: new Date()
      updatedAt: new Date()
      publishedAt: new Date()
      userId: Meteor.userId()

    flash 'Publishing...', post

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    post = Post.create
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      published: false
      createdAt: new Date()
      updatedAt: new Date()
      userId: Meteor.userId()

    flash 'Saving...', post

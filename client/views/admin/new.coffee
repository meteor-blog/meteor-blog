Template.blogAdminNew.rendered = ->
  $('.post-form').parsley()
  $('[name=title]').focus().val ''

  @editor = ace.edit 'editor'
  @editor.setTheme 'ace/theme/chrome'
  @editor.setFontSize 14
  @editor.renderer.setShowPrintMargin false
  @editor.renderer.setShowGutter false
  @editor.setHighlightActiveLine true
  @editor.getSession().setMode 'ace/mode/markdown'
  @editor.getSession().setUseWrapMode true

  @editor.on 'change', _.debounce((e) =>
    height = @editor.getSession().getDocument().getLength() * @editor.renderer.lineHeight + @editor.renderer.scrollBar.getWidth()
    $('#editor, #preview').height height
    @editor.resize()
  , 250)

  $('.make-switch').bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      $('#editor').hide()
      val = marked @editor.getValue()
      return $('#preview').html(val).show()

    $('#editor').show()
    @editor.focus()
    $('#preview').hide()

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
      body: tpl.editor.getValue()
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
      body: tpl.editor.getValue()
      published: false
      createdAt: new Date()
      updatedAt: new Date()
      userId: Meteor.userId()

    if post.errors
      return alert(_(post.errors[0]).values()[0])

    flash 'Saving...', post

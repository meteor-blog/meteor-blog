Template.blogAdminNew.rendered = ->
  $('.post-form').parsley()

  #tpl.editor.remove 'resources'
  #tpl.editor.unload()

  @editor = new EpicEditor
    container: 'editor',
    basePath: '/packages/blog/public/epiceditor'
    autogrow: true
    focusOnLoad: true
    #button: false
    theme:
      editor: '/themes/editor/epic-grey.css'
      preview: '/themes/preview/github.css'

  #page = Page.first name: 'resources'
  @editor.load()
  #@editor.importFile 'resources', page.text

  $('.make-switch').bootstrapSwitch().on 'switch-change', (e, data) =>
    if data.value
      return @editor.preview()

    @editor.edit()

Template.blogAdminNew.events

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    Post.create
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      published: true
      createdAt: new Date()
      userId: Meteor.userId()

    $(e.currentTarget).html '<i class="icon-globe"> Published'
    $('.status').hide().html('Saved &amp; Published').fadeIn 'slow'
    setTimeout ->
      $('.status').fadeOut('slow')
    , 2500

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    if not $('.post-form').parsley 'validate'
      return

    Post.create
      title: $('[name=title]').val()
      body: tpl.editor.exportFile()
      published: false
      createdAt: new Date()
      userId: Meteor.userId()

    $('.status').hide().html('Saved').fadeIn 'slow'
    setTimeout ->
      $('.status').fadeOut 'slow'
    , 2500

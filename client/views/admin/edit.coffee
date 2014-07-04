getPost = ->
  (Post.first Session.get('postId')) or {}

# Add new lines after block elements (visual)
prettyHtml = (html) ->
  block = /\<\/(address|article|aside|audio|blockquote|canvas|dd|div|dl|fieldset|figcaption|figure|footer|form|h1|h2|h3|h4|h5|h6|header|hgroup|hr|noscript|ol|li|output|p|pre|section|table|tfoot|ul|video)\>(?!\n)/gmi
  html.replace(block, (match) ->
    "#{match}\n"
  )

makeEditor = ->
  editor = new MediumEditor '.editable',
    placeholder: 'Start typing...'
    buttonLabels: 'fontawesome'
    buttons:
      ['bold', 'italic', 'underline', 'anchor', 'pre', 'header1', 'header2', 'orderedlist', 'unorderedlist', 'quote', 'image']

  $(@find '.editable').mediumInsert
    editor: editor
    enabled: true
    addons:
      images:
        uploadFile: ($placeholder, file, that) ->
          id = Files.insert
            _id: Random.id()
            contentType: 'image/jpeg'

          $.ajax
            type: "post"
            url: "/fs/#{id}"
            xhr: ->
              xhr = new XMLHttpRequest()
              xhr.upload.onprogress = that.updateProgressBar
              xhr

            cache: false
            contentType: false
            complete: (jqxhr) ->
              that.uploadCompleted { responseText: "/fs/#{id}" }, $placeholder
              return

            processData: false
            data: that.options.formatData(file)

      embeds: {}

  editor

Template.visualEditor.rendered = ->
  @editor = makeEditor.call @

Template.previewEditor.rendered = ->
  @editor = makeEditor.call @
  $editable = @$('.editable')
  $html = @$('.html-editor')

  $html.height($editable.height())
  $editable.on('input', ->
    $html.val($editable.html().trim())
    $html.height($editable.height())
  )

Template.blogAdminEdit.helpers
  post: ->
    getPost()

  editor: ->
    template: Session.get('editorTemplate')
    post: Session.get('currentPost')

setEditMode = (mode) ->
  Session.set('editorTemplate', "#{mode}Editor")
  $('.edit-mode a').removeClass('selected')
  $(".#{mode}-toggle").addClass('selected')

Template.blogAdminEdit.events
  'click .mediumInsert-action': (e, tpl) ->
    # Don't let the medium insert plugin submit the form
    e.preventDefault()
    e.stopPropagation()

  'click .visual-toggle': ->
    post = getPost()
    post.body = $('.html-editor').val()?.trim()
    Session.set('currentPost', post)
    setEditMode 'visual'

  'click .html-toggle': ->
    post = getPost()
    post.body = prettyHtml($('.editable').html()?.trim())
    Session.set('currentPost', post)
    setEditMode 'html'

  'click .preview-toggle': ->
    if $('.editable').get(0)
      post = getPost()
      post.body = prettyHtml($('.editable').html()?.trim())
    else
      post = getPost()
      post.body = $('.html-editor').val()?.trim()

    Session.set('currentPost', post)
    setEditMode 'preview'

  'keyup .html-editor': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    $editable.html($html.val())
    $html.height($editable.height())

  'blur [name=title]': (e, tpl) ->
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Post.slugify(title)

  'submit form': (e, tpl) ->
    e.preventDefault()
    form = $(e.currentTarget)

    # Make paragraphs commentable
    $('.editable', form).find('p').each(->
      $(this).addClass('commentable-section').attr('data-section-id', $(this).index() + 1)
    )

    if $('.editable', form).get(0)
      body = $('.editable', form).html().trim()
    else
      body = $('.html-editor', form).val().trim()

    slug = $('[name=slug]', form).val()

    if not body
      return alert 'Blog body is required'

    attrs =
      title: $('[name=title]', form).val()
      tags: $('[name=tags]', form).val()
      slug: slug
      body: body
      updatedAt: new Date()

    if getPost().id
      post = getPost().update attrs
      if post.errors
        return alert(_(post.errors[0]).values()[0])

      Router.go 'blogAdmin'
    else
      Meteor.call 'doesBlogExist', slug, (err, exists) ->
        if not exists
          attrs.userId = Meteor.userId()
          post = Post.create attrs

          if post.errors
            return alert(_(post.errors[0]).values()[0])

          Router.go 'blogAdmin'

        else
          return alert 'Blog with this slug already exists'

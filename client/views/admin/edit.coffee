## METHODS


# Return current post if we are editing one, or empty object if this is a new
# post that has not been saved yet.
getPost = ->
  (Post.first Session.get('postId')) or {}

# Find tags using typeahead
substringMatcher = (strs) ->
  (q, cb) ->
    matches = []
    pattern = new RegExp q, 'i'

    _.each strs, (ele) ->
      if pattern.test ele
        matches.push
          val: ele

    cb matches

# Pretty up HTML for HTML mode
prettyHtml = (html) ->
  html_beautify(html,
    preserve_newlines: false
    indent_size: 2
    wrap_line_length: 0
  )

# Help return medium editor's contents
MediumEditor.prototype.scrubbed = ->
  @serialize()['element-0'].value

# Set up the medium editor with image upload
makeEditor = (tpl) ->
  editor = new MediumEditor '.editable',
    placeholder: 'Start typing...'
    buttonLabels: 'fontawesome'
    buttons:
      ['bold', 'italic', 'underline', 'anchor', 'pre', 'header1', 'header2', 'orderedlist', 'unorderedlist', 'quote', 'image']

  $(tpl.find '.editable').mediumInsert
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

      #embeds: {}

  editor

# Toggle between visual and HTML mode
setEditMode = (tpl, mode) ->
  tpl.$('.editable').toggle()
  tpl.$('.html-editor').toggle()
  tpl.$('.edit-mode a').removeClass 'selected'
  tpl.$(".#{mode}-toggle").addClass 'selected'

# Highlight code blocks
highlightSyntax = (tpl) ->
  if Blog.settings.syntaxHighlighting
    hljs.configure userBR: true

    br2nl = (i, html) ->
      html
        # medium-editor leaves <br>'s in <pre> tags, which screws up
        # highlight.js. Replace them with actual newlines.
        .replace(/<br>/g, "\n")
        # Strip out highlight.js tags so we don't create them multiple times
        .replace(/<[^>]+>/g, '')

    # Remove 'hljs' class so we don't create it multiple times
    tpl.$('pre').removeClass('hljs').html(br2nl).each (i, block) ->
      hljs.highlightBlock(block)

# Save
save = (tpl, cb) ->
  $form = tpl.$('form')
  $editable = $('.editable', $form)

  # Make paragraphs commentable
  i = $editable.find('p[data-section-id]').length + 1
  $editable.find('p:not([data-section-id])').each ->
    $(this).addClass('commentable-section').attr('data-section-id', i)
    i++

  # Highlight code blocks
  highlightSyntax tpl

  if $editable.is(':visible')
    editor = makeEditor tpl
    body = editor.scrubbed()
  else
    body = $('.html-editor', $form).val().trim()

  if not body
    return cb(null, new Error 'Blog body is required')

  slug = $('[name=slug]', $form).val()

  attrs =
    title: $('[name=title]', $form).val()
    tags: $('[name=tags]', $form).val()
    slug: slug
    body: body
    updatedAt: new Date()

  if getPost().id
    # Next line necessary for https://github.com/meteor/meteor/issues/1964
    $editable.html ''
    post = getPost().update attrs
    if post.errors
      return cb(null, new Error _(post.errors[0]).values()[0])
    cb(null)

  else
    Meteor.call 'doesBlogExist', slug, (err, exists) ->
      if not exists
        attrs.userId = Meteor.userId()
        # Next line necessary for https://github.com/meteor/meteor/issues/1964
        $editable.html ''
        post = Post.create attrs
        if post.errors
          return cb(null, new Error _(post.errors[0]).values()[0])
        cb(null)
      else
        return cb(null, new Error 'Blog with this slug already exists')


## TEMPLATE CODE


Template.blogAdminEdit.rendered = ->
  # Tags
  @$('input[data-role="tagsinput"]').tagsinput
    confirmKeys: [13, 44, 9]

  @$('input[data-role="tagsinput"]').tagsinput('input').typeahead(
    highlight: true,
    hint: false
  ,
    name: 'tags'
    displayKey: 'val'
    source: substringMatcher Tag.first().tags
  ).bind('typeahead:selected', $.proxy (obj, datum) ->
    this.tagsinput('add', datum.val)
    this.tagsinput('input').typeahead('val', '')
  , $('input[data-role="tagsinput"]'))

  # Medium editor
  makeEditor @

Template.blogAdminEdit.helpers
  post: ->
    getPost()

Template.blogAdminEdit.events
  # Don't let the medium insert plugin submit the form
  'click .mediumInsert-action': (e, tpl) ->
    e.preventDefault()
    e.stopPropagation()

  # Toggle between VISUAL/HTML modes
  'click .visual-toggle': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    if $editable.is(':visible')
      return

    post = getPost()
    post.body = $html.val()?.trim()
    highlightSyntax tpl
    setEditMode tpl, 'visual'

  'click .html-toggle': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    if $html.is(':visible')
      return

    editor = makeEditor tpl
    $html.val prettyHtml(editor.scrubbed())
    setEditMode tpl, 'html'
    $html.height($editable.height())

  # Automatically change height on editor areas
  'keyup .html-editor': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    $editable.html($html.val())
    $html.height($editable.height())

  # Autosave
  'input .editable, keyup .html-editor': _.debounce (e, tpl) ->
    save tpl, (res, err) ->
      if err
        return Notifications.error '', err.message
      Notifications.success '', 'Saved'
  , 5000

  'blur [name=title]': (e, tpl) ->
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Post.slugify(title)

  'submit form': (e, tpl) ->
    e.preventDefault()
    save tpl, (res, err) ->
      if err
        return Notifications.error '', err.message
      Router.go 'blogAdmin'

## METHODS


# Return current post if we are editing one, or empty object if this is a new
# post that has not been saved yet.
getPost = ->
  (Post.first()) or {}

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

# Toggle between visual and HTML mode
setEditMode = (tpl, mode) ->
  tpl.$('.editable').toggle()
  tpl.$('.html-editor').toggle()
  tpl.$('.edit-mode a').removeClass 'selected'
  tpl.$(".#{mode}-toggle").addClass 'selected'

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
  tpl.editor.highlightSyntax()

  if $editable.is(':visible')
    body = tpl.editor.contents()
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
    post = getPost().update attrs
    if post.errors
      return cb(null, new Error _(post.errors[0]).values()[0])
    cb null

  else
    Meteor.call 'doesBlogExist', slug, (err, exists) ->
      if not exists
        attrs.userId = Meteor.userId()
        post = Post.create attrs
        if post.errors
          return cb(null, new Error _(post.errors[0]).values()[0])
        cb post.id
      else
        return cb(null, new Error 'Blog with this slug already exists')


## TEMPLATE CODE


Template.blogAdminEdit.rendered = ->

  # We can't use reactive template vars for contenteditable :-(
  # (https://github.com/meteor/meteor/issues/1964). So we put the single-post
  # subscription in an autorun. If we're loading an existing post, once its
  # ready, we populate the contents via jQquery. The catch is, we only want to
  # run it once because when we set the contents, we lose our cursor position
  # (re: autosave).
  ranOnce = false
  @autorun =>
    sub = Meteor.subscribe 'singlePostById', Session.get('postId')
    # Load post body initially, if any
    if sub.ready() and not ranOnce
      ranOnce = true
      post = getPost()
      if post?.body
        @$('.editable').html post.body
        @$('.html-editor').html post.body

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
  @editor = BlogEditor.make @

Template.blogAdminEdit.helpers
  post: ->
    getPost()

Template.blogAdminEdit.events
  # Toggle between VISUAL/HTML modes
  'click .visual-toggle': (e, tpl) ->
    if tpl.$('.editable').is(':visible')
      return

    tpl.editor.highlightSyntax()
    setEditMode tpl, 'visual'

  'click .html-toggle': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')
    if $html.is(':visible')
      return

    $html.val tpl.editor.pretty()
    setEditMode tpl, 'html'
    $html.height($editable.height())

  # Copy HTML content to visual editor and autosize height
  'keyup .html-editor': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    $editable.html($html.val()?.trim())
    $html.height($editable.height())

  # Autosave
  'input .editable, keyup .html-editor': _.debounce (e, tpl) ->
    save tpl, (id, err) ->
      if err
        return Notifications.error '', err.message

      if id
        # If new blog post, subscribe to the new post and update URL
        Session.set 'postId', id
        path = Router.path 'blogAdminEdit', id: id
        IronLocation.set path, { replaceState: true, skipReactive: true }

      Notifications.success '', 'Saved'
  , 8000

  'blur [name=title]': (e, tpl) ->
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Post.slugify(title)

  'submit form': (e, tpl) ->
    e.preventDefault()
    save tpl, (id, err) ->
      if err
        return Notifications.error '', err.message
      Router.go 'blogAdmin'

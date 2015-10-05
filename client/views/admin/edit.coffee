
# ------------------------------------------------------------------------------
# METHODS


# Reads image dimensions and takes a callback callback passes params (width,
# height, fileName)
readImageDimensions = (file, cb) ->
  reader = new FileReader
  image = new Image
  reader.readAsDataURL file

  reader.onload = (_file) ->
    image.src = _file.target.result

    image.onload = ->
      w = @width
      h = @height
      n = file.name
      cb(w,h,n) # callback with width, height as params
      return

    image.onerror = ->
      alert 'Invalid file type: ' + file.type


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
  editor = BlogEditor.make tpl

  # Make paragraphs commentable
  # remove duplicates
  $editable.find('p[data-section-id]').each ->
    sec_id = $(this).attr 'data-section-id'
    if $editable.find("p[data-section-id=#{sec_id}]").length > 1
      $editable.find("p[data-section-id=#{sec_id}]:gt(0)").removeAttr 'data-section-id'
  # decorate
  i = $editable.find('p[data-section-id]').length + 1
  $editable.find('p:not([data-section-id])').each ->
    $(this).addClass('commentable-section').attr('data-section-id', i)
    i++

  # Highlight code blocks
  editor.highlightSyntax()

  if $editable.is(':visible')
    body = editor.contents()
  else
    body = $('.html-editor', $form).val().trim()

  if not body
    return cb(null, new Error 'Blog body is required')

  slug = $('[name=slug]', $form).val()
  description = $('[name=description]', $form).val()

  attrs =
    title: $('[name=title]', $form).val()
    tags: $('[name=tags]', $form).val()
    slug: slug
    description: description
    body: body
    updatedAt: new Date()

  post = Blog.Post.first(Session.get('blog.postId'))
  if post?
    post.update attrs
    if post.errors
      return cb(null, new Error _(post.errors[0]).values()[0])
    cb null

  else
    Meteor.call 'doesBlogExist', slug, (err, exists) ->
      if not exists
        attrs.userId = Meteor.userId()
        post = Blog.Post.create attrs
        if post.errors
          return cb(null, new Error _(post.errors[0]).values()[0])
        cb post.id
      else
        return cb(null, new Error 'Blog with this slug already exists')


# ------------------------------------------------------------------------------
# TEMPLATE CODE


Template.blogAdminEdit.onCreated ->
  id = @data.id if @data
  Session.set 'blog.postId', id

  postSub = null
  authorsSub = @subscribe 'blog.authors'
  tagsSub = @subscribe 'blog.postTags'

  @autorun =>
    postSub = @subscribe 'blog.singlePostById', Session.get('blog.postId')

  @subsReady = new ReactiveVar false
  @autorun =>
    if postSub.ready() and authorsSub.ready() and tagsSub.ready() and !Meteor.loggingIn()
      @subsReady.set true

  @autorun ->
    Router.go 'blogIndex' if not Meteor.userId()


Template.blogAdminEdit.onRendered ->
  Meteor.call 'isBlogAuthorized', @data.id, (err, authorized) =>
    if not authorized
      return Router.go('/blog')

  # We can't use reactive template vars for contenteditable :-(
  # (https://github.com/meteor/meteor/issues/1964). So we put the single-post
  # subscription in an autorun and update the contents the old-fashioned way via
  # jQuery.
  @autorun =>
    if @subsReady.get()
      Meteor.defer =>
        # Wait a tick for template to re-render
        post = Blog.Post.first(Session.get('blog.postId'))
        if post?
          # Load post body initially, if any
          @$('.editable').html post.body
          @$('.html-editor').html post.body

        # Tags
        $tags = @$('[data-role=tagsinput]')
        $tags.tagsinput confirmKeys: [13, 44, 9]
        $tags.tagsinput('input').typeahead(
          highlight: true,
          hint: false
        ,
          name: 'tags'
          displayKey: 'val'
          source: substringMatcher Blog.Tag.first().tags
        ).bind 'typeahead:selected', (obj, datum) ->
          $tags.tagsinput 'add', datum.val
          $tags.tagsinput('input').typeahead 'val', ''

        # Create the Medium editor
        BlogEditor.make @

Template.blogAdminEdit.helpers
  post: -> Blog.Post.first(Session.get('blog.postId')) or {}
  subsReady: -> Template.instance().subsReady.get()

Template.blogAdminEdit.events
  # Toggle between VISUAL/HTML modes
  'click [data-action=toggle-visual]': (e, tpl) ->
    if tpl.$('.editable').is(':visible')
      return

    BlogEditor.make(tpl).highlightSyntax()
    setEditMode tpl, 'visual'

  'click [data-action=toggle-html]': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')
    if $html.is(':visible')
      return

    if $editable.find('.medium-insert-images').length is 0
      $html.val BlogEditor.make(tpl).pretty()
    setEditMode tpl, 'html'
    $html.height($editable.height())

  # Copy HTML content to visual editor and autosize height
  'keyup .html-editor': (e, tpl) ->
    $editable = tpl.$('.editable')
    $html = tpl.$('.html-editor')

    $editable.html($html.val()?.trim())
    $html.height($editable.height())

  # Autosave
  'input .editable, keydown .editable, keydown .html-editor': _.debounce (e, tpl) ->
    save tpl, (id, err) ->
      if err
        return Notifications.error '', err.message

      if id
        # If new blog post, subscribe to the new post and update URL
        Session.set 'blog.postId', id
        path = Router.path 'blogAdminEdit', id: id
        Iron.Location.go path, { replaceState: true, skipReactive: true }

      Notifications.success '', 'Saved'
  , 8000

  'blur [name=title]': (e, tpl) ->
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Blog.Post.slugify(title)

  'click [data-action=delete-featured]': (e, tpl) ->
    e.preventDefault()
    @update
      featuredImageWidth: null
      featuredImageHeight: null
      featuredImageName: null
      featuredImage: null
      titleBackground: null

  'change [name=featured-image]': (e, tpl) ->
    the_file = $(e.currentTarget)[0].files[0]
    post = @
    # get dimensions
    readImageDimensions the_file, (width, height, name) ->
      post.update
        featuredImageWidth: width
        featuredImageHeight: height
        featuredImageName: name
    # S3
    if Meteor.settings?.public?.blog?.useS3
      Blog.S3Files.insert the_file, (err, fileObj) ->
        Tracker.autorun (c) ->
          theFile = Blog.S3Files.find({_id: fileObj._id}).fetch()[0]
          if theFile.isUploaded() and theFile.url?()
            if post.id?
              post.update
                featuredImage: theFile.url()
              Notifications.success '', 'Featured image saved!'
              c.stop()
    # Local Filestore
    else
      Blog.FilesLocal.insert the_file, (err, fileObj) ->
        Tracker.autorun (c) ->
          theFile = Blog.FilesLocal.find({_id: fileObj._id}).fetch()[0]
          if theFile.isUploaded() and theFile.url?()
            if post.id?
              post.update
                featuredImage: theFile.url()
              Notifications.success '', 'Featured image saved!'
              c.stop()

  'change [name=background-title]': (e, tpl) ->
    $checkbox = $(e.currentTarget)
    @update
      titleBackground: $checkbox.is(':checked')

  'submit form': (e, tpl) ->
    e.preventDefault()
    save tpl, (id, err) ->
      if err
        return Notifications.error '', err.message
      Router.go 'blogAdmin'

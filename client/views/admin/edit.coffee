## METHODS


# Return current post if we are editing one, or empty object if this is a new
# post that has not been saved yet.
getPost = (id) ->
  (Post.first( { _id : id } ) ) or {}

# reads image dimensions and takes a callback
# callback passes params (width, height, fileName)
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

  if getPost( Session.get('postId') ).id
    post = getPost( Session.get('postId') ).update attrs
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
      post = getPost( Session.get('postId') )
      if post?.body
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
        source: substringMatcher Tag.first().tags
      ).bind 'typeahead:selected', (obj, datum) ->
        $tags.tagsinput 'add', datum.val
        $tags.tagsinput('input').typeahead 'val', ''

      # Medium editor
      BlogEditor.make @

Template.blogAdminEdit.helpers
  post: ->
    getPost( Session.get('postId') )

Template.blogAdminEdit.events
  # Toggle between VISUAL/HTML modes
  'click .visual-toggle': (e, tpl) ->
    if tpl.$('.editable').is(':visible')
      return

    BlogEditor.make(tpl).highlightSyntax()
    setEditMode tpl, 'visual'

  'click .html-toggle': (e, tpl) ->
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
        Session.set 'postId', id
        path = Router.path 'blogAdminEdit', id: id
        Iron.Location.go path, { replaceState: true, skipReactive: true }

      Notifications.success '', 'Saved'
  , 8000

  'blur [name=title]': (e, tpl) ->
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Post.slugify(title)

  'click [data-action=delete-featured]': (e, tpl) ->
    e.preventDefault()
    post = getPost Session.get('postId')
    post.update
      featuredImageWidth: null
      featuredImageHeight: null
      featuredImageName: null
      featuredImage: null
      titleBackground: null

  'change [name=featured-image]': (e, tpl) ->
    the_file = $(e.currentTarget)[0].files[0]
    post = getPost Session.get('postId')
    # get dimensions
    readImageDimensions the_file, (width, height, name) ->
      post.update
        featuredImageWidth: width
        featuredImageHeight: height
        featuredImageName: name
    # S3
    if Meteor.settings?.public?.blog?.useS3
      S3Files.insert the_file, (err, fileObj) ->
        Tracker.autorun (c) ->
          theFile = S3Files.find({_id: fileObj._id}).fetch()[0]
          if theFile.isUploaded() and theFile.url?()
            if post.id?
              post.update
                featuredImage: theFile.url()
              c.stop()
    # Local Filestore
    else
      # cfs id
      id = FilesLocal.insert
        _id: Random.id()
        contentType: 'image/jpeg'
      # format data
      formdata = new FormData()
      formdata.append('file', the_file)
      $.ajax
        type: "post"
        url: "/fs/#{id}"
        xhr: ->
          xhr = new XMLHttpRequest()
          xhr.upload.onprogress = (data) ->
            # upload progress is avilable here if needed
          xhr
        cache: false
        contentType: false
        processData: false
        data: formdata
        complete: (jqxhr) ->
          if post.id?
            post.update
              featuredImage: "/fs/#{id}"
            Notifications.success '', 'Featured image saved!'

  'change [name=background-title]': (e, tpl) ->
    $checkbox = $(e.currentTarget)
    getPost(Session.get("postId")).update
      titleBackground: $checkbox.is(':checked')

  'submit form': (e, tpl) ->
    e.preventDefault()
    save tpl, (id, err) ->
      if err
        return Notifications.error '', err.message
      Router.go 'blogAdmin'

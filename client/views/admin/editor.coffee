class @BlogEditor extends MediumEditor

  # FACTORY
  @make: (tpl) ->
    $editable = $ '.editable'

    if $editable.data('mediumEditor')
      return $editable.data('mediumEditor')

    # Set up the medium editor with image upload
    editor = new BlogEditor $editable[0],
      buttonLabels: 'fontawesome'
      extensions:
        placeholder:
          text: ''
      toolbar:
        buttons: ['bold', 'italic', 'underline', 'anchor', 'pre', 'h1', 'h2', 'orderedlist', 'unorderedlist', 'quote', 'image']

    # Disable medium toolbar if we are in a code block
    editor.subscribe 'showToolbar', (e) =>
      if @inPreformatted()
        editor.toolbar.hideToolbar()

    # Enable medium-editor-insert-plugin for images
    tpl.$('.editable').mediumInsert
      editor: editor
      enabled: true
      addons:
        images:
          fileUploadOptions:
            submit: (e, data) ->
              self = tpl.$('.editable').data('plugin_mediumInsertImages')
              files = data.files
              # Use CollectionFS + Amazon S3
              if Meteor.settings?.public?.blog?.useS3
                for file in files
                  Blog.S3Files.insert file, (err, fileObj) ->
                    Tracker.autorun (c) ->
                      theFile = Blog.S3Files.find({_id: fileObj._id}).fetch()[0]
                      if theFile.isUploaded() and theFile.url?()
                        # insert-plugin assumes a server response, but we are
                        # cooler than that so pretend this came from a server
                        self.uploadDone e,
                          result:
                            files: [ url: theFile.url() ]
                          context: data.context
                        c.stop()
              # Use Local Filestore
              else
                for file in files
                  Blog.FilesLocal.insert file, (err, fileObj) ->
                    Tracker.autorun (c) ->
                      theFile = Blog.FilesLocal.find({_id: fileObj._id}).fetch()[0]
                      if theFile.isUploaded() and theFile.url?()
                        # insert-plugin assumes a server response, but we are
                        # cooler than that so pretend this came from a server
                        self.uploadDone e,
                          result:
                            files: [ url: theFile.url() ]
                          context: data.context
                        c.stop()

        #embeds: {}


    $editable.data 'mediumEditor', editor
    editor

  # INSTANCE METHODS

  constructor: ->
    @init.apply @, arguments

  # Return medium editor's contents
  contents: ->
    @serialize()['element-0'].value

  # Return medium editor's contents thru HTML beautifier
  pretty: ->
    html_beautify @contents(),
      preserve_newlines: false
      indent_size: 2
      wrap_line_length: 0

  # Highlight code blocks
  highlightSyntax: ->
    hljs.configure userBR: true

    br2nl = (i, html) ->
      html
        # medium-editor leaves <br>'s in <pre> tags, which screws up
        # highlight.js. Replace them with actual newlines.
        .replace(/<br>/g, "\n")
        # Strip out highlight.js tags so we don't create them multiple times
        .replace(/<[^>]+>/g, '')

    # Remove 'hljs' class so we don't create it multiple times
    $(@elements[0]).find('pre').removeClass('hljs').html(br2nl).each (i, block) ->
      hljs.highlightBlock block

  @inPreformatted: ->
    node = document.getSelection().anchorNode
    current = if node and node.nodeType == 3 then node.parentNode else node

    loop
      if current.nodeType == 1
        if current.tagName.toLowerCase() is 'pre'
          return true

        # do not traverse upwards past the nearest containing editor
        if current.getAttribute('data-medium-element')
          return false
      current = current.parentNode
      unless current
        break
    false

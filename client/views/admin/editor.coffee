class @BlogEditor extends MediumEditor

  # FACTORY
  @make: (tpl) ->
    $editable = $ '.editable'

    if $editable.data('mediumEditor')
      return $editable.data('mediumEditor')

    # Set up the medium editor with image upload
    editor = new BlogEditor $editable[0],
      placeholder: ''
      firstHeader: 'h1'
      secondHeader: 'h2'
      buttonLabels: 'fontawesome'
      buttons:
        ['bold', 'italic', 'underline', 'anchor', 'pre', 'header1', 'header2', 'orderedlist', 'unorderedlist', 'quote', 'image']
      onShowToolbar: =>
        # Disable medium toolbar if we are in a code block
        if @inPreformatted()
          editor.toolbar.hideToolbar()


    ###
    tpl.$('.editable').mediumInsert
      editor: editor
      enabled: true
      addons:
        images:
          uploadFile: ($placeholder, file, that) ->
            # Use CollectionFS + Amazon S3
            if Meteor.settings?.public?.blog?.useS3
              FS.Utility.eachFile event, (file) ->
                S3Files.insert file, (err, fileObj) ->
                  Tracker.autorun (c) ->
                    theFile = S3Files.find({_id: fileObj._id}).fetch()[0]
                    if theFile.isUploaded() and theFile.url?()
                      that.uploadCompleted { responseText: theFile.url() }, $placeholder
                      c.stop()
                      return
                    else
                      $progress = $('.progress:first', this.$el)
                      complete = theFile.uploadProgress() ? 0
                      $progress.attr 'value', complete
                      $progress.html complete
            # Use Local Filestore
            else
              id = FilesLocal.insert
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
    ###


    $editable.data 'mediumEditor', editor
    editor

  # INSTANCE METHODS

  constructor: ->
    @init.apply @, arguments

    # Don't let the medium insert plugin submit the form
    #$('form').on 'click', (event) ->
      #if $(event.target).is '.mediumInsert' then event.preventDefault();

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

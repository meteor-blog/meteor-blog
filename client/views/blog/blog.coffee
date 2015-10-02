Template.blogIndex.rendered = ->
  # Page Title
  document.title = "Blog"
  if Blog.settings.title
    document.title += " | #{Blog.settings.title}"



Template.blogShowBody.rendered = ->

  Meteor.call 'isBlogAuthorized', @id, (err, authorized) =>
      if authorized
        Session.set 'canEditPost', authorized

  #
  # SIDECOMMENTS.JS
  #

  settings = Blog.settings.comments
  # check if useSideComments config is true (default is null)
  if settings.useSideComments
    SideComments = require 'side-comments'

    # check if config allows anonymous commenters (default is null)
    if settings.allowAnonymous and !Meteor.user()
      commentUser =
        name: 'Anonymous'
        avatarUrl: settings.defaultImg
        id: 0
    else if Meteor.user()
      # check username
      the_user = Meteor.user()
      possible_names = [                 # if more than one variable
        the_user.username                # contains a usable name, the match
        the_user.services?.google?.name  # with the lowest index will be chosen
        the_user.profile?.name
        the_user.emails?[0].address
      ]
      chosen_name = null
      possible_names.every (name) ->
        if name?
          if typeof name is "string" and name.length > 0
            chosen_name = name
            false
         else
            true
      if Meteor.user().profile?[settings.userImg]
        avatar = Meteor.user().profile[settings.userImg]
      else
        avatar = settings.defaultImg
      commentUser =
        name: chosen_name
        avatarUrl: avatar
        id: Meteor.userId()
    else
      commentUser =
        name: 'Login to Comment'
        avatarUrl: settings.defaultImg
        id: 0

    # load existing comments
    existingComments = []
    Blog.Comment.where(slug: Session.get('slug')).forEach((comment) ->
      comment.comment.id = comment._id
      sec = _(existingComments).findWhere(sectionId: comment.sectionId.toString())
      if sec
        sec.comments.push comment.comment
      else
        existingComments.push
          sectionId: comment.sectionId.toString()
          comments: [comment.comment]
    )

    # add side comments
    sideComments = new SideComments '#commentable-area', commentUser, existingComments

    # side comments events
    sideComments.on 'commentPosted', (comment) ->
      if settings.allowAnonymous or Meteor.user()
        attrs =
          slug: Session.get('slug')
          sectionId: comment.sectionId
          comment:
            authorAvatarUrl: comment.authorAvatarUrl
            authorName: comment.authorName
            authorId: comment.authorId
            comment: comment.comment
        commentId = Blog.Comment.create attrs
        comment.id = commentId
        sideComments.insertComment(comment)
      else
          comment.id = -1
          sideComments.insertComment
            sectionId: comment.sectionId
            authorName: comment.authorName
            comment: 'Please login to post comments'

    sideComments.on 'commentDeleted', (comment) ->
      if Meteor.user()
        Blog.Comment.destroyAll comment.id
        sideComments.removeComment comment.sectionId, comment.id

  ####

  # Page Title
  document.title = "#{@data.title}"
  if Blog.settings.title
    document.title += " | #{Blog.settings.title}"

  # Hide draft posts from crawlers
  if not @data.published
    $('<meta>', { name: 'robots', content: 'noindex,nofollow' }).appendTo 'head'

  # featured image resize
  if Session.get "postHasFeaturedImage"
    post = Blog.Post.first({slug: Router.current().params.slug})
    $(window).resize ->
      Session.set "fullWidthFeaturedImage", $(window).width() < post.featuredImageWidth
    $(window).trigger "resize" # so it runs once


Template.blogShowBody.events
  'click [data-action=edit-post]': (event, template) ->
    event.preventDefault()
    postId = Blog.Post.first({slug: Router.current().params.slug})._id
    Router.go 'blogAdminEdit', {id: postId}

Template.blogShowBody.helpers
  isAdmin: () ->
    Session.get "canEditPost"
  shareData: () ->
    post = Blog.Post.first slug: Session.get('slug')

    {
      title: post.title,
      excerpt: post.excerpt,
      description: post.description,
      author: post.authorName(),
      thumbnail: post.thumbnail()
    }


Template.disqus.rendered = ->

  if Blog.settings.comments.disqusShortname
    # Don't load the Disqus embed.js into the DOM more than once
    if window.DISQUS
      # If we've already loaded, call reset instead. This will find the correct
      # thread for the current page URL. See:
      # http://help.disqus.com/customer/portal/articles/472107-using-disqus-on-ajax-sites
      post = @data

      window.DISQUS.reset
        reload: true
        config: ->
          @page.identifier = post.id
          @page.title = post.title
          @page.url = window.location.href
    else
      disqus_shortname = Blog.settings.comments.disqusShortname
      disqus_identifier = @data.id
      disqus_title = @data.title
      disqus_url = window.location.href
      disqus_developer = 1

      dsq = document.createElement("script")
      dsq.type = "text/javascript"
      dsq.async = true
      dsq.src = "//" + disqus_shortname + ".disqus.com/embed.js"
      (document.getElementsByTagName("head")[0] or document.getElementsByTagName("body")[0]).appendChild dsq

Template.disqus.helpers
  useDisqus: ->
    Blog.settings.comments.disqusShortname

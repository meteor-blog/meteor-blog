getComment = (id)->
  Comment.first slug: Session.get('slug'), sectionId: id

Template.blogShowBody.rendered = ->

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
      name = if Meteor.user().username then Meteor.user().username else Meteor.user().emails[0].address
      if Meteor.user().profile?[settings.userImg]
        avatar = Meteor.user().profile[settings.userImg]
      else
        avatar = settings.defaultImg
      commentUser =
        name: name
        avatarUrl: avatar
        id: Meteor.userId()
    else
      commentUser =
        name: 'Login to Comment'
        avatarUrl: settings.defaultImg
        id: 0

    # load existing comments
    existingComments = []
    Comment.where(slug: Session.get('slug')).forEach((comment) ->
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
        commentId = Comment.create attrs
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
        Comment.destroyAll comment.id
        sideComments.removeComment comment.sectionId, comment.id

  ####

  # Hide draft posts from crawlers
  if not @data.published
    $('<meta>', { name: 'robots', content: 'noindex,nofollow' }).appendTo 'head'

  $('meta[property^="og:"]').remove()
  $('meta[property^="twitter:"]').remove()

  #
  # OpenGraph tags
  #

  $('<meta>', { property: 'og:type', content: 'article' }).appendTo 'head'
  $('<meta>', { property: 'og:site_name', content: location.hostname }).appendTo 'head'
  $('<meta>', { property: 'og:url', content: location.origin + location.pathname }).appendTo 'head'
  $('<meta>', { property: 'og:title', content: @data.title }).appendTo 'head'
  $('<meta>', { property: 'og:description', content: @data.excerpt }).appendTo 'head'

  img = @data.thumbnail()
  if img
    if not /^http(s?):\/\/+/.test(img)
      img = location.origin + img
    $('<meta>', { property: 'og:image', content: img }).appendTo 'head'

  #
  # Twitter cards
  #

  $('<meta>', { property: 'twitter:card', content: 'summary' }).appendTo 'head'
  # What should go here?
  #$('<meta>', { property: 'twitter:site', content: '' }).appendTo 'head'

  author = @data.author()
  if author.profile and author.profile.twitter
    $('<meta>', { property: 'twitter:creator', content: author.profile.twitter }).appendTo 'head'

  if author.profile and author.profile.profileUrl
    $('<link>', { href: author.profile.profileUrl, rel: 'author' }).appendTo 'head'

  $('<meta>', { property: 'twitter:url', content: location.origin + location.pathname }).appendTo 'head'
  $('<meta>', { property: 'twitter:title', content: @data.title }).appendTo 'head'
  $('<meta>', { property: 'twitter:description', content: @data.excerpt }).appendTo 'head'
  $('<meta>', { property: 'twitter:image:src', content: img }).appendTo 'head'

  #
  # Twitter share button
  #

  base = "https://twitter.com/intent/tweet"
  url = encodeURIComponent location.origin + location.pathname
  text = encodeURIComponent @data.title
  href = base + "?url=" + url + "&text=" + text

  if author.profile and author.profile.twitter
    href += "&via=" + author.profile.twitter

  $(".tw-share").attr "href", href

  #
  # Facebook share button
  #

  base = "https://www.facebook.com/sharer/sharer.php"
  url = encodeURIComponent location.origin + location.pathname
  title = encodeURIComponent @data.title
  summary = encodeURIComponent @data.excerpt
  href = base + "?s=100&p[url]=" + url + "&p[title]=" + title + "&p[summary]=" + summary

  if img
    href += "&p[images][0]=" + encodeURIComponent img

  $(".fb-share").attr "href", href

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

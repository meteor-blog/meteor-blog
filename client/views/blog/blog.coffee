getComment = (id)->
  Comment.first slug: Session.get('slug'), sectionId: id

Template.blogShow.rendered = ->

  # Add SideComments
  Meteor.call 'showSideComments', (err, show) =>
    if show
      SideComments = require 'side-comments'
      commentUser =
        name: Meteor.user().username
        avatarUrl: 'http://f.cl.ly/items/0s1a0q1y2Z2k2I193k1y/default-user.png'
        id: Meteor.userId()
      existingComments = []
      @data.comments.forEach((section)->
        existingComments.push(
          sectionId: section.sectionId.toString()
          comments: section.comments
        )
      )
      sideComments = new SideComments '#commentable-area', commentUser, existingComments
      sideComments.on 'commentPosted', (comment) ->
        attrs =
          authorAvatarUrl: comment.authorAvatarUrl
          authorName: comment.authorName
          comment: comment.comment
        if getComment(comment.sectionId)
          newComment = getComment(comment.sectionId)
          newComment.comments.push attrs
          newComment.update comments: newComment.comments
        else
          Comment.create slug: Session.get('slug'), sectionId: comment.sectionId, comments: [attrs]
        sideComments.insertComment(comment)

Template.blogShowBody.rendered = ->

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

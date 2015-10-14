
# ------------------------------------------------------------------------------
# BLOG INDEX


Template.blogIndex.onCreated ->
  @tag = new ReactiveVar null
  @autorun =>
    @tag.set Blog.Router.getParam 'tag'

  if not Session.get('blog.postLimit')
    if Blog.settings.pageSize
      Session.set 'blog.postLimit', Blog.settings.pageSize

  authorsSub = Blog.subs.subscribe 'blog.authors'
  postsSub = null

  @autorun =>
    if @tag.get()
      postsSub = Blog.subs.subscribe 'blog.taggedPosts', @tag.get()
    else
      postsSub = Blog.subs.subscribe 'blog.posts', Session.get('blog.postLimit')

  @blogReady = new ReactiveVar false
  @autorun =>
    if authorsSub.ready() and postsSub.ready()
      @blogReady.set true

Template.blogIndex.onRendered ->
  # Page Title
  document.title = "Blog"
  if Blog.settings.title
    document.title += " | #{Blog.settings.title}"

Template.blogIndex.helpers
  blogReady: -> Template.instance().blogReady.get()
  posts: ->
    tag = Template.instance().tag.get()
    if tag
      Blog.Post.where({ tags: tag }, { sort: publishedAt: -1 })
    else
      Blog.Post.where({}, { sort: publishedAt: -1 })

# Provide data to custom templates, if any
Meteor.startup ->
  if Blog.settings.blogIndexTemplate
    customIndex = Blog.settings.blogIndexTemplate
    Template[customIndex].onCreated Template.blogIndex._callbacks.created[0]
    Template[customIndex].helpers
      posts: Template.blogIndex.__helpers.get('posts')
      blogReady: Template.blogIndex.__helpers.get('blogReady')


# ------------------------------------------------------------------------------
# SHOW BLOG


Template.blogShow.onCreated ->
  @slug = new ReactiveVar null
  @autorun =>
    @slug.set Blog.Router.getParam 'slug'

  postSub = Blog.subs.subscribe 'blog.singlePostBySlug', @slug.get()
  commentsSub = Blog.subs.subscribe 'blog.commentsBySlug', @slug.get()
  authorsSub = Blog.subs.subscribe 'blog.authors'

  @blogReady = new ReactiveVar false
  @autorun =>
    if postSub.ready() and commentsSub.ready() and authorsSub.ready() and !Meteor.loggingIn()
      @blogReady.set true

Template.blogShow.helpers
  blogReady: -> Template.instance().blogReady.get()
  post: -> Blog.Post.first slug: Template.instance().slug.get()
  notFound: ->
    if Blog.settings.blogNotFoundTemplate
      Blog.settings.blogNotFoundTemplate
    else
      notFound = Blog.Router.getNotFoundTemplate()
      if notFound
        return notFound
      else if Blog.Router.getParam('slug')
        Blog.Router.notFound()

# Provide data to custom templates, if any
Meteor.startup ->
  if Blog.settings.blogShowTemplate
    customShow = Blog.settings.blogShowTemplate
    Template[customShow].onCreated Template.blogShow._callbacks.created[0]
    Template[customShow].helpers
      post: Template.blogShow.__helpers.get('post')
      blogReady: Template.blogShow.__helpers.get('blogReady')


renderSideComments = null


Template.blogShowBody.onRendered ->
  Meteor.call 'isBlogAuthorized', @data.id, (err, authorized) =>
    # Can view?
    if @data.mode is 'draft'
      return Blog.Router.go('/blog') unless authorized

    # Can edit?
    if authorized
      Session.set 'blog.canEditPost', authorized

  # Page Title
  document.title = "#{@data.title}"
  if Blog.settings.title
    document.title += " | #{Blog.settings.title}"

  # Hide draft/private posts from crawlers
  if @data.mode isnt 'public'
    $('<meta>', { name: 'robots', content: 'noindex,nofollow' }).appendTo 'head'

  # Featured image resize
  if @data.featuredImage
    $(window).resize =>
      Session.set "blog.fullWidthFeaturedImage", $(window).width() < @data.featuredImageWidth
      if Session.get "blog.fullWidthFeaturedImage"
        Session.set "blog.fullWidthFeaturedImageHeight", ($(window).width()/@data.featuredImageWidth)*@data.featuredImageHeight
    $(window).trigger "resize" # so it runs once

  # Sidecomments.js
  renderSideComments.call @, @data.slug

editPost = (e, tpl) ->
  e.preventDefault()
  postId = Blog.Post.first(slug: @slug)._id
  Blog.Router.go 'blogAdminEdit', id: postId

Template.blogShowBody.events
  'click [data-action=edit-post]': editPost

Template.blogShowBody.helpers
  isAdmin: -> Session.get "blog.canEditPost"
  shareData: ->
    post = Blog.Post.first slug: @slug
    title: post.title,
    excerpt: post.excerpt,
    description: post.description,
    author: post.authorName(),
    thumbnail: post.thumbnail()

Template.blogShowFeaturedImage.events
  'click [data-action=edit-post]': editPost

Template.blogShowFeaturedImage.helpers
  isAdmin: -> Session.get "blog.canEditPost"
  fullWidthFeaturedImage: -> Session.get "blog.fullWidthFeaturedImage"
  fullWidthFeaturedImageHeight: -> Session.get "blog.fullWidthFeaturedImageHeight"


# ------------------------------------------------------------------------------
# SIDECOMMENTS.js


renderSideComments = (slug) ->

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
    Blog.Comment.where(slug: slug).forEach((comment) ->
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
          slug: slug
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


# ------------------------------------------------------------------------------
# DISQUS COMMENTS


Template.disqus.onRendered ->

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

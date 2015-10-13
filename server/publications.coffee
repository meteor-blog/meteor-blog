
#
# Public Publications
#

Meteor.publish 'blog.commentsBySlug', (slug) ->
  check slug, String

  Blog.Comment.find slug: slug

Meteor.publish 'blog.singlePostBySlug', (slug) ->
  check slug, String

  Blog.Post.find slug: slug

Meteor.publish 'blog.posts', (limit) ->
  check limit, Match.Optional(Number)

  if not limit? then return @ready()

  Blog.Post.find
    mode: 'public'
  ,
    fields: body: 0
    sort: publishedAt: -1
    limit: limit

Meteor.publish 'blog.taggedPosts', (tag) ->
  check tag, String

  Blog.Post.find
    mode: 'public'
    tags: tag
  ,
    fields: body: 0
    sort: publishedAt: -1

Meteor.publish 'blog.authors', ->
  ids = _.uniq(_.pluck(Blog.Post.all(fields: userId: 1), 'userId'))

  Blog.Author.find
    _id: $in: ids
  ,
    fields:
      profile: 1
      username: 1
      emails: 1


#
# Admin Publications
#

Meteor.publish 'blog.singlePostById', (id) ->
  check id, Match.OneOf(String, null)

  if not @userId
    return @ready()

  Blog.Post.find _id: id

Meteor.publish 'blog.postTags', ->
  if not @userId
    return @ready()

  initializing = true
  tags = Blog.Tag.first().tags

  handle = Blog.Post.find({}, {fields: {tags: 1}}).observeChanges
    added: (id, fields) =>
      if fields.tags
        doc = Blog.Tag.first()
        tags = _.uniq doc.tags.concat(Blog.Post.splitTags(fields.tags))
        doc.update tags: tags
        @changed('blog_tags', 42, {tags: tags}) unless initializing

    changed: (id, fields) =>
      if fields.tags
        doc = Blog.Tag.first()
        tags = _.uniq doc.tags.concat(Blog.Post.splitTags(fields.tags))
        doc.update tags: tags
        @changed('blog_tags', 42, {tags: tags}) unless initializing

  initializing = false
  @added 'blog_tags', 42, {tags: tags}
  @ready()
  @onStop -> handle.stop()

Meteor.publish 'blog.postForAdmin', ->
  if not @userId
    return @ready()

  sel = {}

  # If author role is set, and user is author, only return user's posts
  if Blog.settings.authorRole and Roles.userIsInRole(@userId, Blog.settings.authorRole)
    sel = userId: @userId

  Blog.Post.find sel,
    fields: body: 0
    sort: publishedAt: -1

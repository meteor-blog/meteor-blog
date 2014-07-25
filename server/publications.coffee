
#
# Public Publications
#

Meteor.publish 'commentsBySlug', (slug) ->
  check slug, String

  Comment.find slug: slug

Meteor.publish 'singlePostBySlug', (slug) ->
  check slug, String

  Post.find slug: slug

Meteor.publish 'posts', (limit) ->
  check limit, Match.Optional(Number)

  Post.find { published: true },
    fields: body: 0
    sort: publishedAt: -1
    limit: limit

Meteor.publish 'taggedPosts', (tag) ->
  check tag, String

  Post.find
    published: true
    tags: tag
  ,
    fields: body: 0
    sort: publishedAt: -1

Meteor.publish 'authors', ->
  ids = _.pluck Post.all fields: id: 1, 'id'

  Author.find
    id: $in: ids
  ,
    fields:
      profile: 1
      username: 1
      emails: 1


#
# Admin Publications
#

Meteor.publish 'singlePostById', (id) ->
  check id, String

  if not @userId
    return @ready()

  Post.find _id: id

Meteor.publish 'postTags', ->
  if not @userId
    return @ready()

  initializing = true
  tags = Tag.first().tags

  handle = Post.find({}, {fields: {tags: 1}}).observeChanges
    added: (id, fields) =>
      if fields.tags
        doc = Tag.first()
        tags = _.uniq doc.tags.concat(Post.splitTags(fields.tags))
        doc.update tags: tags
        @changed('blog_tags', 42, {tags: tags}) unless initializing

    changed: (id, fields) =>
      if fields.tags
        doc = Tag.first()
        tags = _.uniq doc.tags.concat(Post.splitTags(fields.tags))
        doc.update tags: tags
        @changed('blog_tags', 42, {tags: tags}) unless initializing

  initializing = false
  @added 'blog_tags', 42, {tags: tags}
  @ready()
  @onStop -> handle.stop()

Meteor.publish 'postForAdmin', ->
  if not @userId
    return @ready()

  sel = {}

  # If author role is set, and user is author, only return user's posts
  if Blog.settings.authorRole and Roles.userIsInRole(@userId, Blog.settings.authorRole)
    sel = userId: @userId

  Post.find sel,
    fields: body: 0
    sort: publishedAt: -1

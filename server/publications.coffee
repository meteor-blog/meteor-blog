Meteor.publish 'singlePostBySlug', (slug) ->
  check slug, String

  Post.find slug: slug

Meteor.publish 'singlePostById', (id) ->
  check id, String

  Post.find _id: id

Meteor.publish 'posts', (limit) ->
  check limit, Match.Optional(Number)

  Post.find {},
    fields:
      body: 0
    sort:
      publishedAt: -1
    limit:
      limit

Meteor.publish 'taggedPosts', (tag) ->
  check tag, String

  Post.find {tags: tag},
    fields:
      body: 0
    sort:
      publishedAt: -1

Meteor.publish 'authors', ->
  ids = _.pluck Post.all
    fields:
      id: 1
  , 'id'

  Author.find
    id:
      $in: ids
  ,
    fields:
      profile: 1
      username: 1
      emails: 1

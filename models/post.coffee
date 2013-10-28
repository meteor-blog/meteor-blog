class @Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @belongs_to: [
    name: 'user'
  ]

  @before_create: (post) ->
    post.slug = URLify2 post.title
    post

Post._collection.allow
  insert: (userId, item) ->
    userId

  update: (userId, item, fields) ->
    userId

  remove: (userId, item) ->
    userId

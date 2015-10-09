class Blog.Comment extends Minimongoid

  @_collection: new Meteor.Collection 'blog_comments'

  post: ->
    Blog.Post.first @postId

Blog.Comment._collection.allow
  insert: (userId, doc) ->
    !!userId
  update: (userId, doc, fields, modifier) ->
    doc.comment.authorId == userId
  remove: (userId, doc) ->
    doc.comment.authorId == userId

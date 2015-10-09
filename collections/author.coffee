class Blog.Author extends Minimongoid

  @_collection: Meteor.users

  posts: ->
    Blog.Post.where userId: @id

  @current: ->
    if Meteor.userId()
      Blog.Author.init Meteor.user()

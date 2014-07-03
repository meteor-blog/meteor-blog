class @Comment extends Minimongoid

  @_collection: new Meteor.Collection 'blog_comments'

  @belongs_to: [
    name: 'post'
    identifier: 'postId'
  ]

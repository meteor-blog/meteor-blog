class @Comment extends Minimongoid

  @_collection: new Meteor.Collection 'post_comments'

  @belongs_to: [
    name: 'post'
    identifier: 'postId'
  ]

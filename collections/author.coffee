class @Author extends Minimongoid

  @_collection: Meteor.users

  @has_many: [
    name: 'posts'
    foreign_key: 'userId'
  ]

  @current: ->
    if Meteor.userId()
      Author.init Meteor.user()

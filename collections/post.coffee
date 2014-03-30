class @Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @belongs_to: [
    name: 'author'
    identifier: 'userId'
  ]

  @after_save: (post) ->
    # Slug is immutable, for now
    if not post.slug
      post.slug = Post.slugify post.title
    post.tags = Post.splitTags post.tags
    post.excerpt = Post.excerpt post.body

    @_collection.update _id: post.id,
      $set:
        slug: post.slug
        tags: post.tags
        excerpt: post.excerpt

  @slugify: (str) ->
    str.toLowerCase().replace(/[^\w ]+/g, "").replace(RegExp(" +", "g"), "-")

  @splitTags: (str) ->
    str.split(/,\s*/) if str?

  validate: ->
    if not @title
      @error 'title', "Blog title is required"

  html: ->
    marked @body

  thumbnail: ->
    # Convert markdown to HTML
    html = marked @body
    regex = new RegExp /img src=[\'"]([^\'"]+)/ig

    while match = regex.exec html
      return match[1]

  @excerpt: (markdown) ->
    # Convert markdown to HTML
    html = marked markdown

    # Find 1st non-empty paragraph
    matches = html.split /<\/div>|<\/p>|<br><br>|\\n\\n|\\r\\n\\r\\n/m

    i = 0
    ret = ''
    while not ret and matches[i]
      # Strip tags and clean up whitespaces
      ret += matches[i++].replace(/(<([^>]+)>)/ig, ' ').replace('&nbsp;', ' ').trim()

    ret

  authorName: ->
    author = @author()

    if author
      if author.profile and author.profile.firstName and author.profile.lastName
        return "#{author.profile.firstName} #{author.profile.lastName}"

      else if author.profile and author.profile.twitter
        return "<a href=\"http://twitter.com/#{author.profile.twitter}\">#{author.profile.twitter}</a>"

      else if author.username
        return author.username

      else if author.emails and author.emails[0]
        return author.emails[0].address

    'Mystery blogger'

Post._collection.allow
  insert: (userId, item) ->
    Meteor.call 'isBlogAuthorized'

  update: (userId, item, fields) ->
    Meteor.call 'isBlogAuthorized'

  remove: (userId, item) ->
    Meteor.call 'isBlogAuthorized'

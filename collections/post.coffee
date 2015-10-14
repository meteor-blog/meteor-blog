class Blog.Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @after_save: (post) ->
    post.tags = Blog.Post.splitTags post.tags
    post.excerpt = Blog.Post.excerpt post.body if post.body

    @_collection.update _id: post.id,
      $set:
        tags: post.tags
        excerpt: post.excerpt

  @replace_foreign_charts:  (str) ->
    charts =
      'ä|æ|ǽ': 'ae',
      'ö|œ': 'oe',
      'ü': 'ue',
      'Ä': 'Ae',
      'Ü': 'Ue',
      'Ö': 'Oe',
      'À|Á|Â|Ã|Ä|Å|Ǻ|Ā|Ă|Ą|Ǎ': 'A',
      'à|á|â|ã|å|ǻ|ā|ă|ą|ǎ|ª': 'a',
      'Ç|Ć|Ĉ|Ċ|Č': 'C',
      'ç|ć|ĉ|ċ|č': 'c',
      'Ð|Ď|Đ': 'D',
      'ð|ď|đ': 'd',
      'È|É|Ê|Ë|Ē|Ĕ|Ė|Ę|Ě': 'E',
      'è|é|ê|ë|ē|ĕ|ė|ę|ě': 'e',
      'Ĝ|Ğ|Ġ|Ģ': 'G',
      'ĝ|ğ|ġ|ģ': 'g',
      'Ĥ|Ħ': 'H',
      'ĥ|ħ': 'h',
      'Ì|Í|Î|Ï|Ĩ|Ī|Ĭ|Ǐ|Į|İ': 'I',
      'ì|í|î|ï|ĩ|ī|ĭ|ǐ|į|ı': 'i',
      'Ĵ': 'J',
      'ĵ': 'j',
      'Ķ': 'K',
      'ķ': 'k',
      'Ĺ|Ļ|Ľ|Ŀ|Ł': 'L',
      'ĺ|ļ|ľ|ŀ|ł': 'l',
      'Ñ|Ń|Ņ|Ň': 'N',
      'ñ|ń|ņ|ň|ŉ': 'n',
      'Ò|Ó|Ô|Õ|Ō|Ŏ|Ǒ|Ő|Ơ|Ø|Ǿ': 'O',
      'ò|ó|ô|õ|ō|ŏ|ǒ|ő|ơ|ø|ǿ|º': 'o',
      'Ŕ|Ŗ|Ř': 'R',
      'ŕ|ŗ|ř': 'r',
      'Ś|Ŝ|Ş|Š': 'S',
      'ś|ŝ|ş|š|ſ': 's',
      'Ţ|Ť|Ŧ': 'T',
      'ţ|ť|ŧ': 't',
      'Ù|Ú|Û|Ũ|Ū|Ŭ|Ů|Ű|Ų|Ư|Ǔ|Ǖ|Ǘ|Ǚ|Ǜ': 'U',
      'ù|ú|û|ũ|ū|ŭ|ů|ű|ų|ư|ǔ|ǖ|ǘ|ǚ|ǜ': 'u',
      'Ý|Ÿ|Ŷ': 'Y',
      'ý|ÿ|ŷ': 'y',
      'Ŵ': 'W',
      'ŵ': 'w',
      'Ź|Ż|Ž': 'Z',
      'ź|ż|ž': 'z',
      'Æ|Ǽ': 'AE',
      'ß': 'ss',
      'Ĳ': 'IJ',
      'ĳ': 'ij',
      'Œ': 'OE',
      'ƒ': 'f'
    for foreign  , local  of charts
      regex=new RegExp(foreign,'g')
      str=str.replace(regex,local)
    str


  @slugify:  (str) ->

    str=@replace_foreign_charts(str)
    str = str.replace(/^\s+|\s+$/g, '')
    str = str.toLowerCase();
    from = "·/_,:;"
    to = "------"
    l = from.length
    for  i in [0..l]
      str = str.replace(new RegExp(from.charAt(i), 'g'), to.charAt(i))
    str.replace(/[^a-z0-9 -]/g, '').replace(/\s+/g, '-') .replace(/-+/g, '-')

  @splitTags: (str) ->
    if str and typeof str is 'string'
      return str.split(/,\s*/)
    str

  validate: ->
    if not @title
      @error 'title', "Blog title is required"

    if not @slug
      @error 'slug', "Blog slug is required"

  html: ->
    @body

  thumbnail: ->
    if @featuredImage?
      if Meteor.settings?.public?.blog?.useS3
        @featuredImage
      else
        Meteor.absoluteUrl() + @featuredImage.slice(1)
    else
      regex = new RegExp /img src=[\'"]([^\'"]+)/ig
      while match = regex.exec @body
        return match[1]

  @excerpt: (html) ->
    if Blog.settings.excerptFunction?
      Blog.settings.excerptFunction html
    else
      # Find 1st non-empty paragraph
      matches = html?.split /<\/div>|<\/p>|<\/blockquote>|<br><br>|\\n\\n|\\r\\n\\r\\n/m

      i = 0
      ret = ''
      while not ret and matches?[i]
        # Strip tags and clean up whitespaces
        ret += matches[i++].replace(/(<([^>]+)>)/ig, ' ').replace(/(\s\.)/, '.').replace('&nbsp;', ' ').trim()
      ret

  author: ->
    Blog.Author.first @userId

  authorName: ->
    author = @author()

    if author
      if author.profile and author.profile.name
        return author.profile.name

      else if author.profile and author.profile.firstName and author.profile.lastName
        return "#{author.profile.firstName} #{author.profile.lastName}"

      else if author.profile and author.profile.twitter
        return "<a href=\"http://twitter.com/#{author.profile.twitter}\">#{author.profile.twitter}</a>"

      else if author.username
        return author.username

      else if author.emails and author.emails[0]
        return author.emails[0].address

    'Mystery blogger'


#
# Server Methods
#

if Meteor.isServer
  Meteor.methods
    doesBlogExist: (slug) ->
      check slug, String

      !! Blog.Post.first slug: slug

    isBlogAuthorized: () ->
      check arguments[0], Match.OneOf(Object, Number, String, null, undefined)

      if not Meteor.user()
        return false

      # If no roles are set, allow all
      if not Blog.settings.adminRole and not Blog.settings.authorRole
        return true

      # If admin role is set
      if Blog.settings.adminRole
        # And if admin group is set
        if Blog.settings.adminGroup
          # And if user is admin
          if Roles.userIsInRole(@userId, Blog.settings.adminRole, Blog.settings.adminGroup)
            # Then they can do anything
            return true

        # If only admin role is set, and if user is admin
        else if Roles.userIsInRole(@userId, Blog.settings.adminRole)
          # Then they can do anything
          return true


      # If author role is set
      if Blog.settings.authorRole

        # Get the post
        if _.isObject arguments[0]
          post = arguments[0]
        else if _.isNumber(arguments[0]) or _.isString(arguments[0])
          post = Blog.Post.first arguments[0]
        else
          post = null

        # And if author group is set
        if Blog.settings.authorGroup
          # And if user is author
          if Roles.userIsInRole(@userId, Blog.settings.authorRole, Blog.settings.authorGroup)
            if post
              # And if user is author of this post
              if Meteor.userId() is post.userId
                return true
            else
              return true

        # If only author role is passed, and if user is author
        else if Roles.userIsInRole(@userId, Blog.settings.authorRole)
          if post
            # And if user is author of this post
            if Meteor.userId() is post.userId
              return true
          else
            return true


      false


#
# Authorization
#

Blog.Post._collection.allow
  insert: (userId, item) ->
    Meteor.call 'isBlogAuthorized', item

  update: (userId, item, fields) ->
    Meteor.call 'isBlogAuthorized', item

  remove: (userId, item) ->
    Meteor.call 'isBlogAuthorized', item

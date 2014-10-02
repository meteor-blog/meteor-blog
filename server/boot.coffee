##############################################################################
# Server-side config
#

Blog =
  settings:
    adminRole: null
    adminGroup: null
    authorRole: null
    authorGroup: null
    rss:
      title: ''
      description: ''

  config: (appConfig) ->
    @settings = _.extend(@settings, appConfig)

@Blog = Blog

################################################################################
# Bootstrap Code
#

Meteor.startup ->

  ##############################################################################
  # Migrations
  #

  Post._collection._ensureIndex 'slug': 1
  Comment._collection._ensureIndex 'slug': 1

  # Create 'excerpt' field if none
  if Post.where({ excerpt: { $exists: 0 }}).length
    arr = Post.where({ excerpt: { $exists: 0 }})
    i = 0
    while i < arr.length
      obj = arr[i++]
      obj.update({ excerpt: Post.excerpt(obj.body) })

  # Set version flag
  if not Config.first()
    Config.create versions: ['0.5.0']
  else
    Config.first().push versions: '0.5.0'

  # Add side comments
  arr = Post.all()
  i = 0
  while i < arr.length
    obj = arr[i++]
    html = obj.body
    para = /<p[^>]*>/g
    classPattern = /class=[\"|\'].*[\"|\']/g
    if html.indexOf('commentable-section') < 0
      index = 0
      html = html.replace(para, (ele) ->
        if classPattern.test(ele)
          newEle = ele.replace('class=\"', 'class=\"commentable-section')
        else
          newEle = ele.replace('>', ' class=\"commentable-section\">')
        newEle = newEle.replace('>', " data-section-id=\"#{index}\">")
        index++
        return newEle
      )
      obj.update body: html

  # Ensure tags collection is non-empty
  if Tag.count() == 0
    Tag.create
      tags: ['meteor']

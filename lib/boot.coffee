@Blog = {}

Blog.settings =
  comments: {}
  rss: {}
  language: {}

Blog.config = (appConfig) ->
  # No deep extend in underscore :-(
  if appConfig.comments
    @settings.comments = _.extend(@settings.comments, appConfig.comments)
    delete appConfig.comments
  @settings = _.extend(@settings, appConfig)
  
  if appConfig.language
    @settings.language = _.extend(@settings.language, appConfig.language)
    delete appConfig.language
  @settings = _.extend(@settings, appConfig)


##############################################################################
# Server-side config
#


if Meteor.isServer
  Blog.config
    adminRole: null
    adminGroup: null
    authorRole: null
    authorGroup: null
    rss:
      title: ''
      description: ''


################################################################################
# Client-side config
#


if Meteor.isClient
  Blog.config({
    title: ''
    blogIndexTemplate: null
    blogShowTemplate: null
    blogNotFoundTemplate: null
    blogAdminTemplate: null
    blogAdminEditTemplate: null
    blogLayoutTemplate: null
    pageSize: 20
    excerptFunction: null
    syntaxHighlighting: false
    syntaxHighlightingTheme: 'github'
    cdnFontAwesome: true
    comments: {
      allowAnonymous: false
      useSideComments: false
      defaultImg: '/packages/blog/public/default-user.png'
      userImg: 'avatar'
      disqusShortname: null
    }
    language: {
      blogEmpty: 'This blog is looking pretty empty...'
      backToBlogIndex: 'Back to the Blog'
      tags: 'Tags'
      slug: 'Slug'
      metaDescription: 'Meta Description'
      body: 'Body'
      showAsVisual: 'Visual'
      showAsHtml: 'HTML'
      save: 'Save'
      cancel: 'Cancel'
      delete: 'Delete'
      metaAuthorBy: 'By'
      metaAuthorOn: 'on'
      edit: 'Edit'
      areYouSure: 'Are you sure?'
      disqusPoweredBy: 'comments powered by'
      adminHeader: 'Blog Admin'
      addPost: 'Add Blog Post'
      allPosts: 'All Posts'
      myPosts: 'My Posts'
      editPost: 'Edit Post'
      title: 'Title'
      author: 'Author'
      updatedAt: 'Updated At'
      publishedAt: 'Published At'
      visibleTo: 'Visible To'
      featuredImage: 'Featured Image'
      selectFile: 'Select File'
      imageAsBackground: 'Use as background for title'
      enterTag: 'Type in a tag & hit enter'
      postCreateFirst: 'Create the first blog'
      postVisibilityAdmins: 'Me & Admins only'
      postVisibilityLink: 'Anyone with link'
      postVisibilityAnyone: 'The world'
      saved: 'Saved'
      editFeaturedImageSaved: 'Featured image saved'
      editErrorSlugExists: 'Blog with this slug already exists'
      editErrorBodyRequired: 'Blog body is required'
    }})
      


################################################################################
# Both config
#


Blog.config
  basePath: '/blog'
  adminBasePath: '/admin/blog'

Package.describe({
  summary: "A package that provides a blog at /blog"
});

Package.on_use(function(api) {
  api.use([
    'deps',
    'underscore',
    'templating',
    'handlebars',
    'spark',
    'session',
    'coffeescript',
    'iron-router',
    'less'
  ], 'client');
  api.add_files([
    'blog.coffee',
    'router.coffee',
    'blog.less',
    'templates/blog.html'
  ], 'client');
});

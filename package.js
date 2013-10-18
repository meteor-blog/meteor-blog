Package.describe({
  summary: "A package that provides a blog at /blog"
});

Package.on_use(function(api) {

  var both = ['client', 'server'];

  api.use([
    'templating',
    'handlebars',
    'less'
  ], 'client');

  api.add_files([
    'client/stylesheets/lib/bootstrap.css',
    'client/stylesheets/lib/bootstrap-switch.css',
    'client/config.coffee',
    'client/compatibility/bootstrap-switch.js',
    'client/views/admin/admin.less',
    'client/views/admin/admin.html',
    'client/views/admin/new.html',
    'client/views/admin/new.coffee'
  ], 'client');

  api.use([
    'coffeescript',
    'iron-router'
  ], both);

  api.add_files([
    'router.coffee',
  ], both);
});

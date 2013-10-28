Package.describe({
  summary: "A package that provides a blog at /blog"
});

Package.on_use(function(api) {

  var both = ['client', 'server'];

  /**
   * Packages for client
   */

  api.use([
    'templating',
    'handlebars',
    'less',
    'parsleyjs'
  ], 'client');

  /**
   * Files for client
   */

  api.add_files([
    'client/stylesheets/lib/bootstrap.css',
    'client/stylesheets/lib/bootstrap-switch.css',
    'client/config.coffee',
    'client/compatibility/bootstrap-switch.js',
    'client/compatibility/epiceditor.js',
    'client/views/admin/admin.less',
    'client/views/admin/admin.html',
    'client/views/admin/admin.coffee',
    'client/views/admin/new.html',
    'client/views/admin/new.coffee'
  ], 'client');

  /**
   * Static assets for client
   */

  api.add_files([
    'public/epiceditor/themes/base/epiceditor.css',
    'public/epiceditor/themes/editor/epic-dark.css',
    'public/epiceditor/themes/editor/epic-grey.css',
    'public/epiceditor/themes/editor/epic-light.css',
    'public/epiceditor/themes/preview/bartik.css',
    'public/epiceditor/themes/preview/blank.css',
    'public/epiceditor/themes/preview/github.css',
    'public/epiceditor/themes/preview/preview-dark.css',
  ], 'client', { isAsset: true });

  /**
   * Packages for server and client
   */

  api.use([
    'coffeescript',
    'iron-router',
    'accounts-base',
    'minimongoid'
  ], both);

  /**
   * Files for server and client
   */

  api.add_files([
    'router.coffee',
    'models/user.coffee',
    'models/post.coffee'
  ], both);
});

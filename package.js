Package.describe({
  summary: "A package that provides a blog at /blog"
});

Package.on_use(function(api) {
  api.versionsFrom('METEOR@0.9.0');

  var both = ['client', 'server'];

  /**
   * Packages for client
   */

  api.use([
    'session',
    'templating',
    'ui',
    'less',
    'aslagle:reactive-table',
    'joshowens:shareit'
  ], 'client');

  /**
   * Files for client
   */

  api.add_files([
    'client/stylesheets/lib/side-comments/side-comments.css',
    'client/stylesheets/lib/side-comments/default.css',
    'client/stylesheets/lib/medium-editor.css',
    'client/stylesheets/lib/medium-themes/bootstrap.css',
    'client/stylesheets/lib/medium-editor-insert-plugin.css',
    'client/stylesheets/lib/bootstrap-tagsinput.css',
    'client/boot.coffee',
    'client/compatibility/side-comments.js',
    'client/compatibility/medium-editor.js',
    'client/compatibility/medium-editor-insert-plugin.all.js',
    'client/compatibility/bootstrap-tagsinput.js',
    'client/compatibility/typeahead.jquery.js',
    'client/compatibility/beautify-html.js',
    'client/compatibility/highlight.pack.js',
    'client/views/404.html',
    'client/views/dynamic.html',
    'client/views/dynamic.coffee',
    'client/views/admin/admin.less',
    'client/views/admin/admin.html',
    'client/views/admin/admin.coffee',
    'client/views/admin/edit.html',
    'client/views/admin/edit.coffee',
    'client/views/blog/blog.less',
    'client/views/blog/blog.html',
    'client/views/blog/show.html',
    'client/views/blog/blog.coffee',
    'client/views/widget/latest.html',
    'client/views/widget/latest.coffee'
  ], 'client');

  /**
   * Static assets for client
   */

  api.add_files([
    'public/default-user.png',
    'client/stylesheets/images/remove.png',
    'client/stylesheets/images/resize-bigger.png',
    'client/stylesheets/images/resize-smaller.png'
  ], 'client', { isAsset: true });

  /**
   * Files for server
   */

  api.add_files([
    'collections/config.coffee',
    'server/boot.coffee',
    'server/rss.coffee',
    'server/publications.coffee'
  ], 'server');

  /**
   * Packages for server
   */

  Npm.depends({ rss: '0.0.4' });

  /**
   * Packages for server and client
   */

  api.use([
    'coffeescript',
    'deps',
    'cmather:iron-router',
    'accounts-base',
    'mrt:minimongoid',
    'mrt:moment',
    'fileCollection', /**NEEDS FIXED!**/
    'roles'
  ], both);

  /**
   * Files for server and client
   */

  api.add_files([
    'router.coffee',
    'collections/author.coffee',
    'collections/post.coffee',
    'collections/comment.coffee',
    'collections/tag.coffee',
    'collections/files.coffee'
  ], both);
});

Package.on_test(function (api) {
  api.use('blog', ['client', 'server']);
  api.use('tinytest', ['client', 'server']);
  api.use('test-helpers', ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);

  api.add_files('test/server/rss.coffee', 'server');
});

Package.describe({
  summary: "A package that provides a blog at /blog",
  version: "0.6.2",
  name: "ryw:blog",
  git: "https://github.com/Differential/meteor-blog.git"
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.0');

  var both = ['client', 'server'];

  // PACKAGES FOR CLIENT

  api.use([
    'session',
    'templating',
    'ui',
    'less',
    'underscore',
    'aslagle:reactive-table@0.5.5',
    'joshowens:shareit@0.2.0',
    'gfk:notifications@1.0.11'
  ], 'client');

  // FILES FOR CLIENT

  api.addFiles([
    'client/stylesheets/lib/side-comments/side-comments.css',
    'client/stylesheets/lib/side-comments/default.css',
    'client/stylesheets/lib/medium-editor.css',
    'client/stylesheets/lib/medium-themes/bootstrap.css',
    'client/stylesheets/lib/medium-editor-insert-plugin-frontend.css',
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
    'client/views/custom.html',
    'client/views/custom.coffee',
    'client/views/admin/admin.less',
    'client/views/admin/admin.html',
    'client/views/admin/admin.coffee',
    'client/views/admin/edit.html',
    'client/views/admin/editor.coffee',
    'client/views/admin/edit.coffee',
    'client/views/blog/blog.less',
    'client/views/blog/blog.html',
    'client/views/blog/show.html',
    'client/views/blog/blog.coffee',
    'client/views/widget/latest.html',
    'client/views/widget/latest.coffee'
  ], 'client');

  // STATIC ASSETS FOR CLIENT

  api.addFiles([
    'public/default-user.png',
    'client/stylesheets/images/remove.png',
    'client/stylesheets/images/resize-bigger.png',
    'client/stylesheets/images/resize-smaller.png'
  ], 'client', { isAsset: true });

  // FILES FOR SERVER

  api.addFiles([
    'collections/config.coffee',
    'server/boot.coffee',
    'server/rss.coffee',
    'server/publications.coffee'
  ], 'server');

  // PACKAGES FOR SERVER

  Npm.depends({ rss: '0.0.4' });

  // PACKAGES FOR SERVER AND CLIENT

  api.use([
    'coffeescript',
    'deps',
    'iron:router@1.0.0',
    'iron:location@1.0.0',
    'accounts-base',
    'kaptron:minimongoid@0.9.1',
    'mrt:moment@2.8.1',
    'vsivsi:file-collection@0.3.3',
    'alanning:roles@1.2.13',
    'meteorhacks:fast-render@2.0.2',
    'meteorhacks:subs-manager@1.2.0',
    'fortawesome:fontawesome'
  ], both);

  // FILES FOR SERVER AND CLIENT

  api.addFiles([
    'collections/author.coffee',
    'collections/post.coffee',
    'collections/comment.coffee',
    'collections/tag.coffee',
    'collections/files.coffee',
    'router.coffee'
  ], both);
});

Package.onTest(function (api) {
  api.use("ryw:blog", ['client', 'server']);
  api.use('tinytest', ['client', 'server']);
  api.use('test-helpers', ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);

  api.addFiles('test/server/rss.coffee', 'server');
});

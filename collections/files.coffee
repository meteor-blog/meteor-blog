imageStore = new FS.Store.GridFS 'images'
@Images = new FS.Collection 'images', stores: [imageStore]

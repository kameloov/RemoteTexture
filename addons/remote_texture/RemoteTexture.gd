tool
extends ImageTexture
class_name RemoteTexture

enum ImageType {PNG,JPG,AUTO_DETECT}
enum LoadStrategy {DISK_FIRST,REMOTE_FIRST}

export (ImageType) var type = ImageType.AUTO_DETECT;
export (LoadStrategy) var loadPriority = LoadStrategy.DISK_FIRST;
export var url = "";


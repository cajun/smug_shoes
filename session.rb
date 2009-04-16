class Session
  include Singleton
  
  attr_accessor :smug, :albums
  attr_accessor :album, :images, :current_size
  def init
    @smug = Smile::Smug.new
    @smug.auth_anonymously
  end
  
  def smug
    init if( @smug.nil? )
    @smug
  end
  
  def album=( index )
    @album = @albums[index]
    @images = @album.photos
  end
end
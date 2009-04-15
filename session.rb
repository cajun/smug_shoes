class Session
  include Singleton
  
  attr_accessor :smug, :albums
  def init
    @smug = Smile::Smug.new
    @smug.auth_anonymously
  end
  
  def smug
    init if( @smug.nil? )
    @smug
  end
  
  def albums=( value )
    @albums = value
  end
end
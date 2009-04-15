class Shoooes < Shoes
  attr_accessor :header_height
  def init
    @session = Session.instance
    @header_height = 90
    background black
  end
  
  def header
    init
    stack :top => 0, :left => 0, :height => @header_height, :attach => Window do
      background black
      title 'Smug Shoooes!!!', :align => 'center', :stroke => white
      flow do
        inscription em( link( 'Home' ) { default_on_click_home } ), " ",
          em( link( 'SmugMug', :click => 'http://www.smugmug.com/' ) ),
          :align => 'center'
      end
    end
  end
  
  def on_home_click
  end
  
  def default_on_click_home
    on_home_click
    visit( '/' )
  end
  
  def box_background
    background white, :curve => 10
  end

  def unescapeHTML( text )
    CGI.unescapeHTML( text )
  end
  
  def clean_text( text )
    unescapeHTML( text )
  end
  
  def parse_links( text )
    return unless text 
    text.gsub( /\<a.+\>.+\<\/a\>/ ) do |html_link|
      debug html_link
      /\<a href=["|'](.+)["|'] .+\>(.+)\<\/a\>/.match html_link
      debug $1
      debug $2
      link( $2, :click => $1 )
    end
  end
  
  def show_image( photo_url, options )
    if( photo_url )
      image photo_url, options
    else
      para "No Image", :stroke => white
    end
  end
end
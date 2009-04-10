Shoes.setup do
  gem 'cajun-smile'
end

require 'smile'

class SmugShooe < Shoes
  url '/', :index
  
  def index
    @smug = Smile::Smug.new
    @smug.auth_anonymously
    
    para 'Nick Name ( e.g. kleinpeter )'
    @nick = edit_line :text => 'vincentlaforet'
    button 'get albums' do
      fetch_albums
    end
    
    @albums = flow{}
    @photos = flow{}
  end
  
  def fetch_albums
    hash = {}
    
    @smug.albums( :NickName => @nick.text, :Heavy => 1 ).each do |album|
      hash[album.title] = album
    end
    
    @albums.clear
    @photos.clear
    
    @albums.append do
      para 'Albums'
      @albums_list = list_box :items => [ "Pick One" ] + hash.keys do |album_text|
        display_album( hash[album_text.text] )
      end
    end
  end
  
  def default_background
    background gradient slategray, gray
  end
  
  def box_background
    background white, :curve => 10
  end

  def display_album( album )
    @photos.clear
    @photos.append do
      stack :margin => 10, :margin_right => 10 + gutter do
        box_background
        title album.title, :align => 'center'
        para snippet( album.description, 50 ), :align => 'center'
        inscription "Pic Count: #{album.image_count}", :align => 'center'
      end
      
      flow :margin => 10, :margin_right => 10 + gutter do
        box_background
        display_photos( album ) if( album.image_count.to_i > 1 )
      end
    end
  end

  def display_photos( album )
    flow :margin => 5 do
      album.photos.each do |photo|
        pic = show_image photo.thumb_url, :margin => 3, :center => true

        pic.click do |button, left, top|
          photo_and_vid_details( album, photo )
        end 
      end
    end
  end
  
  def show_image( photo_url, options )
    if( photo_url )
      image photo_url, options
    else
      para "No Image"
    end
  end
  
  def snippet( text, length = 20 )
    text[0, length] + "..." if( text.length > length + 1 )
  end

  def photo_and_vid_details( album, photo )
    
    @photos.clear
    @photos.append do
      stack :margin => 10, :margin_right => 10 + gutter do
        box_background
        para( link( album.title ) {
          @vid.stop if( @vid )
          display_album( album ) 
        }, :align => 'center' )
        para "Last Updated: #{photo.last_updated}", :align => 'center'
        para "Caption: #{snippet( photo.caption )}", :align => 'center'
      end
      
      flow :margin => 10, :margin_right => 10 + gutter do
        box_background
        
        %w( thumb small medium large x_large x2_large x3_large original ).each do |p|
          url = photo.send( "#{p}_url" )
          if( url )
            caption link( p, :click => Proc.new do
                @controls.hide if( @controls )
                @status.show if( @status )
                @details.clear
                @details.append do
                  box_background
                  show_image url, :margin => 5, :center => true
                end
              end
            )
          end
        end
        
        %w( video320 video640 video960 video1280 ).each do |p|
          url = photo.send( "#{p}_url" )
          if( url )
            caption link( p, :click => Proc.new do
                @controls.show if( @controls )
                @status.show if( @status )
                @details.clear
                @details.append do
                  box_background
                  stack :margin => 5 do
                    @vid.stop if( @vid )
                    @vid = video url
                  end
                
                  every( 1 ) do |count|
                    unless( @vid.length.nil? )
                      @status.replace "#{@vid.time / 1000} sec / #{@vid.length / 1000} sec"
                    end
                  end
                end
              end
            )
          end
        end
        
        @details = stack :margin => 5, :margin_right => gutter + 5 do
          background white, :curve => 10, :center => true
          image photo.small_url, :margin => 5, :center => true
        end
        
        @controls = para "controls: ",
          link("play")  { @vid.play }, ", ",
          link("pause") { @vid.pause }, ", ",
          link("stop")  { @vid.stop }, ", ",
          link("-5 sec") { @vid.time -= 5000 }, ", ",
          link("+5 sec") { @vid.time += 5000 }, ", "
        
        @status = para ""
        @status.hide
        @controls.hide
      end
    end
  end
  
end


Shoes.app :title => 'Smug Shooe', :width => 800, :height => 800, :resizeable => false
 
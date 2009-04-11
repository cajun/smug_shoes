Shoes.setup do
  sources = [ 'http://gems.rubyforge.org/', 'http://gems.github.com' ]
  gem 'cajun-smile'
end

require 'smile'

class SmugShooe < Shoes
  url '/', :index
  url '/albums', :albums
  url '/photos/(\w+)', :photos
  url '/photo_and_vid_details/(\w+),(\w+)'
  
  def index
    @smug = Smile::Smug.new
    @smug.auth_anonymously
    background black
    
    para 'Nick Name ( e.g. kleinpeter )', :stroke => white
    @nick = edit_line :text => 'vincentlaforet'
    button 'get albums' do
      fetch_albums
    end
    
    @albums = stack :margin => 10, :margin_right => 10 + gutter
    @album_display = flow do
      @photo_vid = stack :margin => 5, :margin_right => 200 + gutter, :attach => Window, 
        :top => 25, :left => 200
      @photos = stack :width => -600, :margin => 5, :margin_right => 5 + gutter, :top => 20,
        :attach => self, :top => 20
    end
  end
  
  def box_background
    background white, :curve => 10
  end
  
  def fetch_albums
    @vid.stop if( @vid )
    @photo_vid.clear
    @albums.clear
    @photos.clear
    
    @albums.append do
      @smug.albums( :NickName => @nick.text, :Heavy => 1 ).each do |album|
        if( album.image_count.to_i > 1 )
          flow :margin => 5 do
            box_background
            first_photo = album.photos.first.thumb_url
          
            if( first_photo )
              stack :width => 200 do
                pic = show_image first_photo, :margin => 6
                pic.click do |button, left, top|
                  @albums.clear
                  display_photos( album )
                end
              end
            
              stack :width => -200 do
                subtitle album.title
                para snippet( album.description, 50 )
                inscription "Pic Count: #{album.image_count}"
              end
            end # if first
          end # if > 1
        end
      end
    end
  end


  def display_photos( album )
    @photos.clear
    @photo_vid.clear
    
    @photos.append do
      album.photos.each do |photo|
        pic = show_image photo.thumb_url, :margin => 3, :center => true

        pic.click do |button, left, top|
          photo_and_vid_details( album, photo )
        end
      end
    end
    @photos.scroll = true
    photo_and_vid_details( album, album.photos.first )
  end
  
  def show_image( photo_url, options )
    if( photo_url )
      image photo_url, options
    else
      para "No Image", :stroke => white
    end
  end
  
  def snippet( text, length = 20 )
    text[0, length] + "..." if( text.length > length + 1 )
  end

  def photo_and_vid_details( album, photo )
    
    @photo_vid.clear
    @photo_vid.append do
      stack :margin => 10, :margin_right => 10 + gutter do
        box_background
        para( 
          link( "View #{album.title} at SmugMug", :click => photo.album_url ), 
          :align => 'center' 
        )
        para "Last Updated: #{photo.last_updated}", :align => 'center'
        para "Caption: #{snippet( photo.caption )}", :align => 'center'
        para( 
          link( 'Back to Albums' ) { fetch_albums }, 
          :align => 'center'
        )
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
                    @vid = video url, :autoplay => true
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


Shoes.app :title => 'Smug Shooe', :width => 800, :height => 650
 
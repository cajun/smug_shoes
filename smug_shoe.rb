Shoes.setup { source 'http://gems.github.com' }

Shoes.setup do
  gem 'cajun-smile'
end

require 'smile'
require 'cgi'

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

class Shooes < Shoes
  attr_accessor :header_height
  def header
    @session = Session.instance
    background black
    @header_height = 90
    stack :top => 0, :left => 0, :height => @header_height, :attach => Window do
      title 'Smug Shooes!!!', :align => 'center', :stroke => white
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
  
  def show_image( photo_url, options )
    if( photo_url )
      image photo_url, options
    else
      para "No Image", :stroke => white
    end
  end
end

class Albums < Shooes
  url '/albums/(\w+)', :index
  
  def index( nick )
    header
    
    @session.albums = @session.smug.albums( :NickName => nick, :Heavy => 1 ).select{ |x| x.image_count.to_i > 1 }
    flow :top => @header_height do
      @session.albums.each_with_index do |album,index|
        flow :margin => 5, :margin_right => 5 + gutter do
          box_background
          stack :width => 200 do
            pic = show_image album.photos.first.thumb_url, :margin => 6
            pic.click do |button, left, top|
              visit( "/images/#{index}" )
            end
          end

          stack :width => -200 do
            para album.title
            inscription unescapeHTML( album.description )
            inscription em "Pic Count: #{album.image_count}"
          end
        end
      end
    end
  end
end

class Images < Shooes
  url '/images/(\d+)', :index
  
  def setup
    @album_display = flow do
      @photo_vid = stack :margin_right => 200 + gutter, 
        :attach => Window, 
        :top => 5, :left => 200
      @photos = stack :width => -600, :margin => 5, :margin_right => 5 + gutter, :top => 20,
        :attach => self, :top => 20
    end
  end
  
  def index( album_number )
    header
    setup
    album = @session.albums[album_number.to_i]

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
   
   def on_home_click
    @vid.stop if( @vid )
   end
   
   def photo_and_vid_details( album, photo )
     @photo_vid.clear
     @photo_vid.append do
       stack :top => @header_height, :margin => 2, :margin_right => 2 + gutter do
         box_background
         inscription( 
           link( "View #{album.title} at SmugMug", :click => photo.album_url ), 
           :align => 'center' 
         )
         inscription em "Last Updated: #{photo.last_updated}", :align => 'center'
         inscription unescapeHTML( photo.caption ), :align => 'center'
       end

       flow :margin => 2, :margin_right => 2 + gutter do
         box_background

         %w( thumb small medium large x_large x2_large x3_large original ).each do |p|
           url = photo.send( "#{p}_url" )
           if( url )
             inscription link( p, :click => Proc.new do
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
             inscription link( p, :click => Proc.new do
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

class SmugShooe < Shooes
  url '/', :index
  
  def index
    header
    
    flow :top => @header_height do
      para 'Nick Name ( e.g. kleinpeter )', :stroke => white
      nick = edit_line :text => 'vincentlaforet'
    
      button 'get albums' do
        visit( "/albums/#{nick.text}" )
      end
    end
  end
end


Shoes.app :title => 'Smug Shooe', :width => 800, :height => 650
 
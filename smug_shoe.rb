Shoes.setup do
  gem 'cajun-smile'
end

require 'smile'

Shoes.app :title => 'Smug Shooe', :width => 1050, :radius => 12 do
  smug = Smile::Smug.new
  smug.auth_anonymously
  
  background gradient slategray, gray
  stroke white
  para 'Enter NickName ( e.g. kleinpeter )'
  @nick = edit_line :text => 'vincentlaforet'
  
  
  button 'get albums' do
    albums_hash = {}
    
    smug.albums( :NickName => @nick.text, :Heavy => 1 ).each do |album|
      albums_hash[album.title] = album
    end
    
    @albums.clear
    @photos.clear
    
    @albums.append do
      para 'Albums'
      @albums_list = list_box :items => [ "Pick One" ] + albums_hash.keys do |album_text|
        display_album( albums_hash[album_text.text] )
      end
    end
  end
  
  @albums = flow{ }
  @photos = flow{ }
  

  def display_album( album )
    @photos.clear
    @photos.append do
      stack do
        background white, :curve => 10, :margin => 10, :margin_right => 10 + gutter
        title album.title, :align => 'center'
        caption album.description, :align => 'center'
        inscription "Pic Count: #{album.image_count}", :align => 'center'
      end
      
      flow :margin => 10, :margin_right => 10 + gutter do
        background white, :curve => 10, :center => true
        display_photos( album)
      end
    end
  end
  
  def display_photos( album )
    flow :margin => 5 do
      album.photos.each do |photo|
        pic = show_image photo.thumb_url, :margin => 3, :center => true

        pic.click do |button, left, top|
          pic_dialog( album, photo )
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
  
  def pic_dialog( album, photo )
    @details = window :title => album.title do
      background gradient slategray, gray
      stack :margin => 5, :margin_right => gutter + 5 do
        background white, :curve => 10, :center => true
        para( link( album.title ), :align => 'center' ).click{ system( photo.album_url ) }
        para "Last Updated: #{photo.last_updated}", :align => 'center'
        para "Caption: #{photo.caption}", :align => 'center'
      end # dialog
      
      flow :margin => 5, :margin_right => gutter + 5 do
        background white, :curve => 10, :center => true, :margin_right => gutter
        %w( thumb small medium large x_large x2_large x3_large original ).each do |p|
          url = photo.send( "#{p}_url" )
          if( url )
            caption link( p, :click => Proc.new do
                @box.clear
                @box.append do
                  background white, :curve => 10, :center => true
                  image url, :margin => 5, :center => true
                end
              end
            )
          end
        end
        
        %w( video320 video640 video960 video1280 ).each do |p|
          url = photo.send( "#{p}_url" )
          if( url )
            caption link( p, :click => Proc.new do
                @box.clear
                @box.append do
                  background white, :curve => 10
                  stack :margin => 5 do
                    @vid = video url
                  end
                
                  para "controls: ",
                    link("play")  { @vid.play }, ", ",
                    link("pause") { @vid.pause }, ", ",
                    link("stop")  { @vid.stop }, ", ",
                    link("-5 sec") { @vid.time -= 5000 }, ", ",
                    link("+5 sec") { @vid.time += 5000 }, ", ",
                    link("done") { @vid.stop; close }
                  
                  @status = para "status: "
                  #every( 1 ) do |count|
                  #  if( @vid.length.nil? )
                  #    @status.text "status: loading#{'.' * ( count % 3 ) }" 
                  #  else
                  #    @status.text "status: #{@vid.time / 1000} / #{@vid.length / 1000}"
                  #  end
                  #end
                end
              end
            )
          end
        end
        
      end
      
      @box = stack :margin => 5, :margin_right => gutter + 5 do
        background white, :curve => 10, :center => true
        image photo.small_url, :margin => 5, :center => true
      end
    end # pic click
  end
end
 
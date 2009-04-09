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
  @nick = edit_line :text => 'kleinpeter'
  
  
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
        background white, :curve => 10, :margin => 10, :margin_right => 10 + gutter, :center => true
        title album.title, :align => 'center'
        subtitle album.description, :align => 'center'
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
        pic = image photo.thumb_url, :margin => 3, :center => true

        pic.click do |button, left, top|
          pic_dialog( album, photo )
        end 
      end
    end
  end
  
  def pic_dialog( album, photo )
    dialog :title => album.title do
      background gradient slategray, gray
      stack :margin => 5, :center => true do
        background white, :curve => 10, :center => true
        para( link( album.title ), :align => 'center' ).click{ system( photo.album_url ) }
        para "Last Updated: #{photo.last_updated}", :align => 'center'
        para "Caption: #{photo.caption}", :align => 'center'
      end # dialog
      
      flow :margin => 5, :center => true do
        background white, :curve => 10, :center => true
        caption link( 'Thumb', :click => Proc.new do
            @box.clear
            @box.append{ image photo.thumb_url, :center => true }
          end
        )
        caption link( 'Small', :click => Proc.new do
            @box.clear
            @box.append{ image photo.small_url, :center => true }
          end
        )
        caption link( 'Medium', :click => Proc.new do
            @box.clear
            @box.append{ image photo.medium_url, :center => true }
          end
        )
        caption link( 'Large', :click => Proc.new do
            @box.clear
            @box.append{ image photo.large_url, :center => true }
          end
        )
      end
      
      @box = stack :margin => 5, :center => true do
        background white, :curve => 10, :center => true
        image photo.small_url, :margin => 3, :center => true
      end
    end # pic click
  end
end
 
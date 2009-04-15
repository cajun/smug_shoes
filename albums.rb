class Albums < Shoooes
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
            inscription clean_text( album.description )
            inscription em "Pic Count: #{album.image_count}"
          end
        end
      end
    end

  end
end
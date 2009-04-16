class Images < Shoooes
  url '/images/(\d+)', :index
  url '/render_image/(\d+)', :render_image
  attr_accessor :current_size, :images, :album
  
  def index( album_number )
    setup( album_number.to_i )
  end
  
  def setup( album_number=nil )
    header
    @session.current_size ||= 'small_url'
    if( album_number )
      @session.album = album_number  if( album_number )

      render_image( 1 )
    end
  end
   
  def on_home_click
    @vid.stop if( @vid )
  end

  def photo_stack
    stack :width => -600, :margin => 5, :margin_right => 5 + gutter, :attach => self, :top => @header_height do
      @session.images.each_with_index do |photo, index|
        pic = show_image photo.thumb_url, :margin => 3, :center => true

        pic.click { visit "/render_image/#{index}" }
      end
    end
  end
   
  def photo_details( photo )
    flow do
      %w( tiny thumb small medium large x_large x2_large x3_large original ).each do |p|
        url = photo.send( "#{p}_url" )
        inscription link( p, :click => photo_proc( url, "#{p}_url" ) ) if( url )
      end
    end
  end

  def photo_proc( url, size )
    Proc.new do
      @vid.stop if( @vid )
      @controls.hide if( @controls )
      @status.hide if( @status )
      @details.clear
      @session.current_size = size
      
      @details.append do
        box_background
        show_image url, :margin => 5, :center => true
      end
    end
  end
  
  def video_details( video )
    flow do
      %w( video320 video640 video960 video1280 ).each do |p|
        url = video.send( "#{p}_url" )
        inscription link( p, :click => video_proc( url ) ) if( url)
      end
    end
  end

  def video_proc( url )
    Proc.new do
      @vid.stop if( @vid )
      @controls.show if( @controls )
      @status.show if( @status )
      @details.clear
      
      @details.append do
        box_background
        stack :margin => 5, :margin_left => 100 do
          @vid = video url, :autoplay => true, :center => true
        end
      end
    end
  end
  
  def render_image( index )
    setup
    photo_stack
    photo = @session.images[index.to_i]
    
    
    stack :margin_right => 200 + gutter, :attach => Window, :top => 5, :left => 200 do
      stack :top => @header_height, :margin => 2, :margin_right => 2 + gutter do
        box_background
        inscription( 
          link( "View #{@session.album.title} at SmugMug", :click => photo.album_url ), 
          :align => 'center' 
        )
        inscription em "Last Updated: #{photo.last_updated}", :align => 'center'
        inscription clean_text( photo.caption ), :align => 'center'
      end

      flow :margin => 2, :margin_right => 2 + gutter do
        box_background
        stack do
          photo_details( photo )
          video_details( photo )
        end


        @details = stack :margin => 5, :margin_right => gutter + 5 do
          box_reverse_background
          image photo.send( "#{@session.current_size}".to_sym ), :margin => 5, :center => true
        end

        @controls = para "controls: ",
          link("play")  { @vid.play }, ", ",
          link("pause") { @vid.pause }, ", ",
          link("stop")  { @vid.stop }, ", ",
          link("-5 sec") { @vid.time -= 5000 }, ", ",
          link("+5 sec") { @vid.time += 5000 }, ", "

        every( 1 ) do |count|
          if( @vid && @vid.length )
            @status.replace "#{@vid.time / 1000} sec / #{@vid.length / 1000} sec"
          end
        end

        @status = para ""
        @status.hide
        @controls.hide
      end
    end
  end
end
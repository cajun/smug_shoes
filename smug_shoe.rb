Shoes.setup { source 'http://gems.github.com' }

Shoes.setup do
  gem 'cajun-smile'
end

require 'smile'
require 'cgi'
require 'session'
require 'shoooes'
require 'albums'
require 'images'


class SmugShooe < Shoooes
  url '/', :index
  
  def index
    header
    
    flow  :top => @header_height do
      para 'Nick Name ( e.g. kleinpeter )', :stroke => white
      nick = edit_line :text => 'vincentlaforet'
    
      button 'get albums' do
        visit( "/albums/#{nick.text}" )
      end
    end


  end
end


Shoes.app :title => 'Smug Shoooes', :width => 800, :height => 650
 
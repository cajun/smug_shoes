Shoes.setup do
  gem 'rest-client'
  gem 'activesupport'
end

require 'smile'

Shoes.app {
  smile = Smile.new
  @note = para 'i am here'
  stack do
   @email = edit_line
   @passd = edit_line
   @push = button 'login'
   
   @push.click {
     if( smile.auth( @email, @passd ) )
       @note.replace ' got in!! '
     else
       @note.replace ' failed '
     end
   }
  end
}
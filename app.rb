require 'rubygems'
require 'sinatra'
require 'active_record'
require "yaml"
require 'maruku'

# settings handling
settings = YAML.load(File.read('config.yaml'))

# database handling
configure do
  ActiveRecord::Base.establish_connection(
	          :adapter => settings['adaptor'],
	          :database => settings['database']
	)
	begin
		ActiveRecord::Schema.define do
			create_table :posts do |t|
				t.text :title
				t.text :content
				t.integer :author
				t.text :url
				t.timestamps
			end
			create_table :authors do |t|
			  t.integer :id
			  t.text :name # for styled names, like "Nick Charlton", instead of "nickcharlton"
			  t.text :username
			  t.text :password
			end
			create_table :tags do |t|
			  t.text :name
			  t.integer :post_id
			end
		end
	rescue ActiveRecord::StatementInvalid
		# Do nothing, since the schema already exists
	end  
end

# initialise the tables
class Post < ActiveRecord::Base
end
class Author < ActiveRecord::Base
  def find(id)
    # looks up an author from their id
    result = Author.find(id)
    
    return result
  end
end
class Tags < ActiveRecord::Base
end

# homepage handling (shows 5 posts)
get '/' do
  # send in our settings
  @settings = settings
  # pull out all of our posts
  @post = Post.find(:all, :order => 'created_at DESC', :limit => 2)
  # tell the template the author
  @author = Author
  # throw in the tags
  erb :article
end

# post handling (shows 1 post)
get '/post/:url' do
  # send in our settings
  @settings = settings
  # pull out all of our which have this url string, but limit it to one.
  @post = Post.find(:all, :conditions => { :url => params['url'] }, :limit => 1)
  
  # tell the template the author
  @author = Author
  # throw in the tags
  erb :article
end

# page handling (pulls a page from page.erb)
get '/articles' do
  # send in our settings
  @settings = settings
  # pull out everything
  @articles = Post.find(:all)
  erb :articles
end

get '/about' do
  @settings = settings
  erb :about
end

get '/projects' do
  @settings = settings
  erb :projects
end

# admin handling
# add a new post
get '/admin/post' do
  erb :admin_post, :layout => false
end

post '/admin/post' do
  post = Post.new(:title =>  params['title'], :content => params['content'], :author => params['author'], :url => params['url'])
  if post.save
    status(201)
    redirect "/post/#{params['url']}"
  else
    status(412)
  end
end

# add a new tag
get '/admin/tags' do
  erb :admin_tags, :layout => false
end

post '/admin/tags' do
  Tags.new(:name => params['name'], :post_id => params['post_id'])
  if tags.save
    status(201)
  else
    status(412)
  end
end


# error handling
not_found do
  @settings = settings
  # tell the visitor that we couldn't find what they were looking for
  @error = 404
  erb :error
end

error do
  @settings = settings
  erb :error
end
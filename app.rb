require 'active_record'
require 'yaml'
require 'maruku'
require 'digest/sha1'

# settings handling
settings = YAML.load(File.read('config.yaml'))
# database settings
database = YAML.load(File.read('database.yaml'))

# database handling
configure do
  ActiveRecord::Base.establish_connection(
	          :adapter => database["production"]["adapter"],
	          :database => database["production"]["database"],
	          :username => database["production"]["username"],
	          :password => database["production"]["password"]
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

helpers do
  def auth!
    if session[:authed] == true
      return true
    else
      return false
    end
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
class Tag < ActiveRecord::Base
end

enable :sessions

# homepage handling (shows 5 posts)
get '/' do
  # send in our settings
  @settings = settings
  # pull out all of our posts
  @post = Post.find(:all, :order => 'created_at DESC', :limit => 2)
  # tell the template the author
  @author = Author
  # tell the view about a false set of tags
  @tags = ""
  erb :article
end

# post handling (shows 1 post)
get '/post/:url' do
  # send in our settings
  @settings = settings
  # pull out all of our which have this url string, but limit it to one.
  @post = Post.find(:all, :conditions => { :url => params['url'] }, :limit => 1)
  
  # check that our post exists.
  if @post.empty?
    raise not_found
  end
  
  # tell the template the author
  @author = Author
  # print out and throw in the tags
  tags = Tag.find(:all, :conditions => { :post_id => @post[0].id })
  
  @tags = ""
  count = 0
  
  for tag in tags
    @tags = @tags + "<a href=\"/search/tag:#{tag.name}\">#{tag.name}</a>"
    count = count + 1
    
    unless count > (tags.length - 1)
      @tags = @tags + ", "
    end
  end
  
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

# search
# form query catch
get '/search' do
  params[:q]
  
  redirect "/search/#{params[:q]}"
end

# search using tags
get '/search/tag::tag' do
  posts = Tag.find(:all, :select => 'post_id AS id', :conditions => { :name => params[:tag] })
  
  @result = Post.find(posts)
  
  @settings = settings
  erb :search
end

# search using a term (although; only the titles, for now)
get '/search/*' do
  @result = Post.find(:all, :conditions => ["title LIKE ?", "#{params['splat']}%"])
  
  @settings = settings
  erb :search
end

# admin handling

# login
get '/admin/login' do
  erb :admin_login, :layout => false
end

post '/admin/auth' do
  user = params['username']
  # hash our password as an SHA1
  hash = Digest::SHA1.hexdigest params['password']
  
  # look for it in the db
  authed = Author.find(:all, :conditions => { :username => user, :password => hash })
  
  # if we found it
  if authed.empty?
    redirect '/admin/login'
  else
    session[:authed] = true
    
    redirect '/'
  end
end

get '/admin/logout' do
  session[:authed] = false
  
  redirect '/'
end

# add a new post
get '/admin/post' do
  auth!
  erb :admin_post, :layout => false
end

post '/admin/post' do
  auth!
  post = Post.new(:title =>  params['title'], :content => params['content'], :author => params['author'], :url => params['url'])
  # if the post saves, try adding tags
  if post.save
    # find out the ID of our added post. (url, as it should be unique).
    saved_post = Post.first(:conditions => "url = '#{params['url']}'")
    # split them up
    tags = params['tags'].split(/, /)
    # add each to the database
    for tag in tags do
    	saved_tags = Tag.new(:name => tag, :post_id => saved_post.id)
    	if saved_tags.save
    	  # do nothing
    	else
    	  raise ActiveRecordError
    	end
    end
    status(201)
    redirect "/post/#{params['url']}"
  else
    status(412)
  end
end

# add a new author (similarly meant as a debug)
# get '/admin/author' do
  #author = Author.new(:name => "Nick Charlton", :username => "nickcharlton", :password => "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")
  #if author.save
   # status(201)
  #else
   # status(412)
  #end
# end


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
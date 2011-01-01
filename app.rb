require 'active_record'
require 'yaml'
require 'maruku'
require 'digest/sha1'
require 'builder'

# config handling
config = YAML.load(File.read('config.yaml'))
# database config
database = YAML.load(File.read('database.yaml'))

# database handling
configure do |settings|
  ActiveRecord::Base.establish_connection(
	          :adapter => database[settings.environment.to_s]["adapter"],
            :database => database[settings.environment.to_s]["database"],
            :username => database[settings.environment.to_s]["username"],
            :password => database[settings.environment.to_s]["password"]
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
			  t.text :email
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
  
  def check_auth
    if !self.auth!
      redirect '/admin/login'
    end
  end
  
  def apply_ordinal(day)
      case day % 100
      when 11..13
        return day.to_s + "th"
      end

      case day % 10
      when 1
        return day.to_s + "st"
      when 2
        return day.to_s + "nd"
      when 3
        return day.to_s + "rd"
      else
        return day.to_s + "th"
      end
  end
end

# initialise the tables
class Post < ActiveRecord::Base
end
class Author < ActiveRecord::Base
end
class Tag < ActiveRecord::Base
end

enable :sessions

# homepage handling (shows 3 posts)
get '/' do
  # send in our settings
  @settings = config
  # make up the page title
  @settings.store('title', "Home")
  # pull out all of our posts
  @post = Post.find(:all, :order => 'created_at DESC', :limit => 3)
  # tell the template the author
  @author = Author
  # tell the view about a false set of tags
  @tags = ""
  erb :article
end

# post handling (shows 1 post)
get '/post/:url/?' do
  # send in our settings
  @settings = config
  # pull out all of our which have this url string, but limit it to one.
  @post = Post.find(:all, :conditions => { :url => params['url'] }, :limit => 1)
  # make up the page title
  @settings.store('title', @post[0].title)
  
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
get '/archives/?' do
  # send in our settings
  @settings = config
  # pull out everything
  @archives = Post.find(:all, :order => 'created_at DESC')
  # make up the page title
  @settings.store('title', 'Archives')
  erb :archives
end

get '/about/?' do
  @settings = config
  # make up the page title
  @settings.store('title', 'About')
  erb :about
end

get '/projects/?' do
  @settings = config
  # make up the page title
  @settings.store('title', 'Projects')
  
  # github_repo_cache
  # (this is handled by a nightly cron job, to bring in my most recent projects)
  @github = YAML.load(File.read('/var/www/apps/blog/shared/github_repo_cache.yaml'))
  
  erb :projects
end

# search
# form query catch
get '/search/?' do
  params[:q]
  
  redirect "/search/#{params[:q]}"
end

# search using tags
get '/search/tag::tag' do
  posts = Tag.find(:all, :select => 'post_id AS id', :conditions => { :name => params[:tag] })
  
  @result = Post.find(posts)
  
  @settings = config
  # make up the page title
  @settings.store('title', 'Search')
  erb :search
end

# search using a term (although; only the titles, for now)
get '/search/:term' do
  @result = Post.find(:all, :conditions => ["title LIKE ?", "%#{params['term']}%"])
  
  @settings = config
  # make up the page title
  @settings.store('title', 'Search')
  erb :search
end

# atom feed
get '/atom.xml' do
  # post data
  @posts = Post.all
  
  # author data
  @author = Author
  
  @last_modified = @posts.first.updated_at
  
  content_type 'application/atom+xml'
  erb :atom, :layout => false
end

# admin handling

# login
get '/login' do
  redirect '/admin/login'
end
get '/admin/login' do
  if self.auth!
    redirect '/'
  end
  
  @settings = config
  # make up the page title
  @settings.store('title', 'Login')
  erb :'admin/login'
end

post '/admin/auth' do
  user = params['username']
  # hash our password as an SHA1
  hash = Digest::SHA1.hexdigest params['password']
  
  # look for it in the db
  authed = Author.find(:all, :conditions => { :username => user, :password => hash })
  #puts authed.to_s
  # if we found it
  if authed.empty?
    redirect '/admin/login'
  else
    session[:authed] = true
    session[:user_id] = authed[0].id
    
    redirect '/'
  end
end

get '/admin/logout' do
  session[:authed] = false
  
  redirect '/'
end

# add a new post
get '/admin/post' do
  check_auth
  
  @settings = config
  # make up the page title
  @settings.store('title', 'New Post')
  erb :'admin/post'
end

post '/admin/post' do
  check_auth
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

# open a post for editing
get '/admin/edit/:id' do
  check_auth
  
  # pull out all of our which have this url string, but limit it to one.
  @post = Post.find(:all, :conditions => { :id => params['id'] }, :limit => 1)
  
  # print out and throw in the tags
  tags = Tag.find(:all, :conditions => { :post_id => @post[0].id })
  
  @tags = ""
  count = 0
  
  for tag in tags
    @tags = @tags + "#{tag.name}"
    count = count + 1
    
    unless count > (tags.length - 1)
      @tags = @tags + ", "
    end
  end
  
  @settings = config
  # make up the page title
  @settings.store('title', 'Editing: ' + @post[0].title)
  
  erb :'admin/edit'
end

# handle POST of edit
post '/admin/edit' do
  check_auth
  
  # first, dump all of the original tags
  Tag.delete_all "post_id = #{params['id']}"
  
  # save most of the details
  post = Post.update(params['id'], {:title =>  params['title'], :content => params['content'], :author => params['author'], :url => params['url']})
  
  # (re)save the tags
  # split them up
  tags = params['tags'].split(/, /)
  # add each to the database
  for tag in tags do
  	saved_tags = Tag.new(:name => tag, :post_id => params['id'])
  	if saved_tags.save
  	  # do nothing
  	else
  	  raise ActiveRecordError
  	end
  end
    status(201)
    redirect "/post/#{params['url']}"
end

get "/admin/settings" do
  check_auth
  
  @author = Author.find(session[:user_id])
  
  @settings = config
  # make up the page title
  @settings.store('title', 'Your Settings')
  
  erb :'admin/settings'
end

post '/admin/settings' do
  check_auth
  
  if params['password'].empty?
    password = params['old_password']
  else 
    password = params['password']
  end
  
  author = Author.update(session[:user_id], {:name => params['name'], :username => params['username'], :email => params['email'], :password => password})
  
  redirect '/admin/settings'
end

# error handling
not_found do
  @settings = config
  # tell the visitor that we couldn't find what they were looking for
  @error = 404
  # make up the page title
  @settings.store('title', "Something's Lost!")
  erb :error
end

error do
  @settings = config
  # make up the page title
  @settings.store('title', 'Something went wrong!')
  erb :error
end
require './config/environment'

class ApplicationController < Sinatra::Base

 	configure do
	    set :public_folder, 'public'
	    set :views, 'app/views'
	    set :sessions, true
		set :session_secret, "password_security"
	end

	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	post "/signup" do
	    if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
	    	user = User.create(:username => params[:username], :email => params[:email], :password => params[:password])
	    	session[:user_id] = user.id
	    	redirect "/home"
		else
	    	redirect "/signup"
		end
	end


	get "/login" do
		erb :login
	end

	post "/login" do
		user = User.find_by(:username => params[:username])
	    if user && user.authenticate(params[:password])
	        session[:user_id] = user.id
	        redirect "/home"
	    else
	        redirect "/login"
	    end
	end

	get "/logout" do
		session.clear
		redirect "/login"
	end

	get "/home" do
		@destinations = Destination.all
		erb :home
	end

	get "/destinations/new" do
		erb :'destinations/new'
	end

	post '/destinations' do 
		@destination = Destination.create(params[:destination])
		if !params["activity"]["name"].empty?
		  @destination.activities << Activity.find_or_create_by(name: params["activity"]["name"])
		end
		@destination.user = current_user
		@destination.save
		redirect to "destinations/#{@destination.id}"
	end

	get '/destinations/:id/edit' do 
		@destination = Destination.find(params[:id])
		erb :'/destinations/edit'
	end

	get '/destinations/:id' do 
		@destination = Destination.find(params[:id])
		erb :'/destinations/show'
	end

	post '/destinations/:id' do 
		@destination = Destination.find(params[:id])
		@destination.update(params["destination"])
		if !params["activity"]["name"].empty?
		  @destination.activities << Activity.find_or_create_by(name: params["activity"]["name"])
		end
		redirect to "destinations/#{@destination.id}"
	end

    # get "/users/:slug" do 
    # 	erb :'/users/show'
    # end

	helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
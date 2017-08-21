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
require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base

 	configure do
	    set :public_folder, 'public'
	    set :views, 'app/views'
	    set :sessions, true
		set :session_secret, "password_security"
		use Rack::Flash
	end

	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	post "/signup" do
	    # if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
	    user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])
	    if user.save
	    	session[:user_id] = user.id
	    	redirect "/home"
		else
			flash[:message] = user.errors.full_messages.join(', ')
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
	    if !params["destination"]["name"].empty? 
			@destination = Destination.create(params[:destination])
			if !params["activity"]["name"].empty?
			  @destination.activities << Activity.find_or_create_by(name: params["activity"]["name"])
			end
			@destination.user = current_user
			@destination.save
			redirect to "destinations/#{@destination.id}"
		else
			flash[:message] = "A destination name is required"
	    	redirect "/destinations/new"
	    end
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
		if !params["destination"]["name"].empty? 
			@destination.update(params["destination"])
			if !params["activity"]["name"].empty?
			  @destination.activities << Activity.find_or_create_by(name: params["activity"]["name"])
			end
			redirect "/destinations/#{@destination.id}"
		else 
			flash[:message] = "Destination name cannot be empty"
	    	redirect "/destinations/#{@destination.id}/edit"
	    end
	end

	delete '/destinations/:id' do  
		# binding.pry
		@destination = Destination.find(params[:id])
		if current_user = @destination.user
			@destination.destroy
		else
			flash[:message] = "You cannot delete destinations you did not create"
		end
		redirect "/home"

	end

	helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
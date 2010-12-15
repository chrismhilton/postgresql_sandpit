class ClientsController < ApplicationController

  def index
    @clients = Client.all
  end
  
  def new
    @client = Client.new
    @client.users.build
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      
      SchemaHelper.create_and_load_subdomain_schema(@client.subdomain)
      
      subdomain = @client.subdomain + "."
      url = [subdomain, request.domain, request.port_string].join
      
      flash[:notice] = "Account registered! Go to http://#{url} to log in."
      
      redirect_to clients_path
    else
      render :action => :new
    end
  end
end
class MyApp < Sinatra::Application
  
  get '/js/:file' do
    file = '/public/js/'+params[:file]
    send_file('public/js/'+params[:file], :disposition => 'inline')
  end

  get '/*' do

    send_file 'public/index.html'

  end

end
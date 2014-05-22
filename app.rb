require 'sinatra'

get '/*' do
  path = params[:splat].first
  "path: #{path}"
end

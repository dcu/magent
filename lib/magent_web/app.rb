module MagentWeb
  class App < Sinatra::Base
    include MagentWeb::MongoHelper

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    set :public, File.expand_path("../../../public", __FILE__)
    set :views, File.expand_path("../../../lib/magent_web/views", __FILE__)

    before do
      @database = Magent.database
    end

    get "/" do
      @queues = self.queues

      haml :index
    end

    get "/status" do
      haml :status
    end

    get "/queues/:id" do
      @queue = @database.collection(params[:id])
      @messages = document_list(@queue)

      haml :"queues/show"
    end

    private
    def error_not_found
      status 404
    end
  end
end

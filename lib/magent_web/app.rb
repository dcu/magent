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

    get "/queues/:id/failed" do
      @queue = @database.collection(params[:id])
      @errors_queue = @database.collection(params[:id]+".errors")
      @errors = document_list(@errors_queue)

      haml :"queues/failed"
    end

    get "/queues/:id/stats" do
      @queue = @database.collection(params[:id])
      @channel_name = channel_name_for(params[:id])
      channel = Magent::GenericChannel.new(@channel_name)

      @stats_collection = channel.stats_collection
      @stats = channel.stats

      haml :"queues/stats"
    end

    get "/queues/:queue_id/retry/:id" do
      @errors_queue = @database.collection(params[:queue_id]+".errors")
      @channel_name = channel_name_for(params[:queue_id])

      channel = Magent::GenericChannel.new(@channel_name)

      doc = @errors_queue.find({:_id => params[:id]}).next_document
      channel.enqueue_error(doc)

      redirect "/queues/#{params[:queue_id]}/failed"
    end

    get "/queues/:queue_id/delete/:id" do
      @errors_queue = @database.collection(params[:queue_id]+".errors")
      @errors_queue.remove(:_id => params[:id])
      redirect "/queues/#{params[:queue_id]}/failed"
    end

    private
    def error_not_found
      status 404
    end
  end
end

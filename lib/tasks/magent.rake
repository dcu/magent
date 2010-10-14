namespace :magent do
  desc "start magent queue"
  task :start do
    if env = Rake::Task["environment"]
      env.invoke
    end

    Magent::Processor.new(Magent::AsyncChannel.new(ENV['QUEUE'] || 'default')).run!
  end

  desc "display all errors"
  task :errors do
    if env = Rake::Task["environment"]
      env.invoke
    end

    channel = Magent::AsyncChannel.new(ENV['QUEUE'] || 'default')

    page = 1

    channel.error_collection.find({}).each do |error|
      puts error.to_json
    end
  end

  desc "remove all errors"
  task :remove_errors do
    if env = Rake::Task["environment"]
      env.invoke
    end

    channel = Magent::AsyncChannel.new(ENV['QUEUE'] || 'default')

    page = 1

    collection = channel.error_collection
    collection.remove({})
  end

  desc "retry all errors"
  task :retry do
    if env = Rake::Task["environment"]
      env.invoke
    end

    channel = Magent::AsyncChannel.new(ENV['QUEUE'] || 'default')

    page = 1

    channel.error_collection.find({}).each do |error|
      channel.error_collection.remove({:_id => error["_id"]})
      Object.module_eval(error["channel_class"]).enqueue(error["message"])
    end
  end
end

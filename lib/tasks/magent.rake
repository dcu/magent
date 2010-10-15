namespace :magent do
  desc "start magent queue"
  task :start do
    if env = Rake::Task["environment"]
      env.invoke
    end
    queue = ENV['QUEUE'] || 'default'
    puts "Starting magent working on #{queue}. #{Magent.config.inspect}"
    Magent::Processor.new(Magent::AsyncChannel.new(queue)).run!
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
      channel.retry_error(error)
    end
  end
end

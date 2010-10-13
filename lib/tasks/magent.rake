namespace :magent do
  desc "start magent queue"
  task :start do
    if env = Rake::Task["environment"]
      env.invoke
    end

    Magent::Processor.new(Magent::AsyncChannel.new(ENV['QUEUE'] || 'default')).run!
  end
end

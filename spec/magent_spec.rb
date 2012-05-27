require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magent" do
  it "should process findable argument" do
    f = Model.new(5)
    Agent.enqueue_job(:do_job, f)

    Agent.should_receive(:do_job).with(f)
    run_jobs
  end

  it "should process a list of findable arguments" do
    f1 = Model.new(5)
    f2 = Model.new(7)
    Agent.enqueue_job(:do_job, [f1, f2])

    Agent.should_receive(:do_job).with([f1, f2])
    run_jobs
  end

  it "should process hashes as arguments" do
    f1 = Model.new(5)

    args = {:foo => [1,2,3], :m => f1,:c => {:f => [1,2,3]}}

    Agent.enqueue_job(:do_job, args)

    Agent.should_receive(:do_job).with(args)
    run_jobs
  end

  it "should process basic types" do
    args = [1,2,3, "1", "2", "3", [1,2,3], {"1" => 2, :"2" => "3"}]
    Agent.enqueue_job(:do_job, *args)
    Agent.should_receive(:do_job).with(*args)
    run_jobs
  end

  it "should be able to process Sets" do
    args = [Set.new([1,2,3])]
    Agent.enqueue_job(:do_job, *args)
    Agent.should_receive(:do_job).with(*args)
    run_jobs
  end

  it "should be able to process a custom class" do
    args = [Custom.new(1,2)]
    Agent.enqueue_job(:do_job, args)
    Agent.should_receive(:do_job).with(args)

    run_jobs
  end

  it "should be able to process a custom array" do
    args = [CustomArray.new([1,2,3,4,5])]

    Agent.enqueue_job(:do_job, *args)
    Agent.should_receive(:do_job).with(*args)
    run_jobs
  end
end

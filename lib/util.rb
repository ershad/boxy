module Util
  def log_time_taken
    start_time = Time.now
    yield
  ensure
    finish_time = Time.now
    log("Time taken: #{(finish_time - start_time).to_i} seconds")
  end

  def log(msgs)
    msgs.split(/[\r\n]+/).each do |msg|
      next if msg.empty?
      puts "\e[1;33m" + msg.to_s + "\e[0m"
      @logger.info "\e[1;33m" + msg.to_s + "\e[0m"
    end
  end
end

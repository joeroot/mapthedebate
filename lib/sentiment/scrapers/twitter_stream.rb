require 'twitter/json_stream'
require 'json'
require 'time'

class TwitterStream

  def self.run filters=nil
    filters = filters || "david cameron,pensions,nhs,miliband,ed balls"
    EventMachine::run {
      stream = Twitter::JSONStream.connect(
        :path    => '/1/statuses/filter.json',
        :auth    => 'mapthedebate:7lEtHvZ1bu',
        :method  => 'POST',
        :content => "track=#{filters}"
      )

      stream.each_item do |item|
        $stdout.print "item: #{item}\n"
        $stdout.flush
        item = JSON.parse(item)
        if !(item["text"].include? "RT")
          item["source"] = "twitter_stream"
          item["source_id"] = item["id"]
          item.delete("id")
          item["posted_at"] = Time.parse item["created_at"]
          item.delete("created_at")
          s = Status::Status.create item
          s.parts_of_speech
          puts "Added Tweet"
          CoreClassifier.classify s
          puts "Classified Tweet"
        end
      end

      stream.on_error do |message|
        $stdout.print "error: #{message}\n"
        $stdout.flush
      end

      stream.on_reconnect do |timeout, retries|
        $stdout.print "reconnecting in: #{timeout} seconds\n"
        $stdout.flush
      end

      stream.on_max_reconnects do |timeout, retries|
        $stdout.print "Failed after #{retries} failed reconnects\n"
        $stdout.flush
      end

      trap('TERM') {  
        stream.stop
        EventMachine.stop if EventMachine.reactor_running? 
      }
    }
    puts "The event loop has ended"
  end
end
# encoding: UTF-8
=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
module BetterCap
module Events

class Queue
class << self
  @@queue    = ::Queue.new
  @@consumer = Thread.new { Queue.consumer_thread }

  def emit( type, data = {}, opts = {} )
    event = {
      :type => type,
      :opts => opts,
      :time => (Time.now.to_f * 1000).floor,
      :data => data
    }
    @@queue.push event
  end

  def consumer_thread
    loop do
      begin
        event = @@queue.pop
        puts "[#{'EVENT'.red}] #{event[:type].to_s.light_blue}"
      rescue Exception => e
        puts e.message
      end
    end
  end
  
  private

  def method_missing( name, *args )
    emit( name.to_sym, *args )
  end
end
end

end
end

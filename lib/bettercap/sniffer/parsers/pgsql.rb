# encoding: UTF-8
=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

module BetterCap
module Parsers
# PgSQL authentication parser.
class PgSQL < Base
  STARTUP_EXPR      = /....\x00\x03\x00\x00user\x00([^\x00]+)\x00database\x00([^\x00]+)/
  MD5_AUTH_REQ_EXPR = /\x52....\x00\x00\x00\x05(....)/
  MD5_PASSWORD_EXPR = /\x70....md5(.+)/

  def on_packet( pkt )
    if pkt.payload =~ STARTUP_EXPR
      StreamLogger.log_raw( pkt, 'PGSQL', "STARTUP #{'username'.blue}='#{$1.yellow}' #{'database'.blue}='#{$2.yellow}'" )
      Events::Queue.new_credentials :type => 'pgsql', :packet => pkt, 
                                    :subtype => 'startup',
                                    :user => $1,
                                    :db => $2

    elsif pkt.payload =~ MD5_AUTH_REQ_EXPR
      salt = $1.reverse.unpack('L')[0]
      StreamLogger.log_raw( pkt, 'PGSQL', "MD5 AUTH REQUEST #{'salt'.blue}=#{sprintf("0x%X", salt).yellow}" )
      Events::Queue.new_credentials :type => 'pgsql', :packet => pkt, 
                                    :subtype => 'md5_auth_request',
                                    :salt => salt

    elsif pkt.payload =~ MD5_PASSWORD_EXPR
      StreamLogger.log_raw( pkt, 'PGSQL', "PASSWORD #{'md5'.blue}='#{$1.yellow}'" )
      Events::Queue.new_credentials :type => 'pgsql', :packet => pkt, 
                                    :subtype => 'md5_auth',
                                    :pass => $1
    end
  end
end
end
end

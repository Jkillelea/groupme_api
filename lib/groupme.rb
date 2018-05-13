require 'pp'
require 'json'
require_relative './api.rb'
require_relative './message.rb'

# Processes output of the web API
class GroupMe
    attr_reader :groups

    # need an API token
    def initialize(token_path)
        @api = Api.new token_path
        @groups = self.group_ids
    end

    # just the id numbers
    def group_ids
        res = JSON.parse(@api.groups.body)['response']
        ids = res.collect {|r| r['id'].to_i }
    end

    def latest_messages(group = @groups[0])
        ids = []
        msgs = JSON.parse @api.messages(group, nil, nil, nil, 100).body
        msgs = msgs['response']['messages'].map {|m| Message.new m }
    end

    def group(i)
        gid = @groups[i]
        JSON.parse(@api.group(gid).body)['response']
    end

    def messages(i)
        Messages.new @api, @groups[i]
    end
end

class Messages
    include Enumerable

    def initialize(api, gid)
        @api       = api
        @gid       = gid
        @before_id = nil
        @since_id  = nil
        @after_id  = nil
        @limit     = 100
        get_msgs # first api call
    end

    def get_msgs
        response = @api.messages(@gid, @before_id, @since_id, @after_id, @limit).body
        if response.nil?
            @ids = []
            @msgs = []
        else
            msgs = JSON.parse response
            msgs = msgs['response']['messages']
            @msgs = msgs.map {|m| Message.new m}
            @ids = msgs.collect {|m| m['id']}
            @before_id = @ids.last
        end
    end

    def each # read all the messsages. All of them
        while !@ids.empty?
            @msgs.each do |m|
                yield m
            end
            get_msgs # fetch more
        end
    end
end

g = GroupMe.new '../token'

msg_enumerator = g.messages 0
msg_enumerator.each do |m|
    puts "#{m['name']}: #{m.likes}"
end




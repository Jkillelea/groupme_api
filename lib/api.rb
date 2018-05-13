require 'net/http'
require 'uri'

# Web API interface. Doesn't do any postprocessing
class Api
    header  = {'Content-Type': 'application/json'}

    def initialize(token_path)
        @token = File.read(token_path).chomp
        @uri   = URI.parse "https://api.groupme.com/v3/?token=#{@token}"
        @http  = Net::HTTP.new @uri.host, @uri.port
        @http.use_ssl = true # gotta add that
    end

    # return all groups
    def groups
        u = @uri.clone
        u.path += 'groups'
        http_get u
    end
    
    # by id number
    def group(id)
        u = @uri.clone
        u.path += "groups/#{id}"
        http_get u
    end

    # get message before a message id
    def messages(group_id, before_id = nil, since_id = nil, after_id = nil, limit = nil)
        u = @uri.clone
        u.path += "groups/#{group_id}/messages"

        u.query += before_id.nil? ? "" : "&before_id=#{before_id}"
        u.query += since_id.nil?  ? "" : "&since_id=#{since_id}"
        u.query += after_id.nil?  ? "" : "&after_id=#{after_id}"
        u.query += limit.nil?     ? "" : "&limit=#{limit}"

        http_get u        
    end

    # get request
    private
    def http_get(req)
        @http.request(Net::HTTP::Get.new(req.request_uri, @header))
    end
    # put request
    private
    def http_put(req)
        @http.request(Net::HTTP::Put.new(req.request_uri, @header))
    end

end

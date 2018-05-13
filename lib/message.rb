class Message
    attr_accessor :data, :keys
    def initialize(data)
        @data = data
        # ["attachments", "avatar_url", "created_at", "favorited_by", "group_id", "id", "name", 
        # "sender_id", "sender_type", "source_guid", "system", "text", "user_id"] (and sometimes 'event')
        @keys = @data.keys
    end

    def [](k)
        @data[k]
    end

    def likes
        self['favorited_by'].length
    end

    def to_s
        "#{self['created_at']} | #{self['name']} | #{self['text']}"
    end
end

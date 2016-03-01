module Europeana
  module OEmbed
    module Responder
      class CREMCNRS < Rich
        def html
          uri = URI.parse(@url)
          id = uri.path.match(%r{/items/([^/]+)/})[1]
          %Q(<iframe width="361" height="215" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" ) +
            %Q(src="http://archives.crem-cnrs.fr/archives/items/#{id}/player/346x130/"></iframe>)
        end

        def width
          361
        end

        def height
          215
        end
      end
    end
  end
end

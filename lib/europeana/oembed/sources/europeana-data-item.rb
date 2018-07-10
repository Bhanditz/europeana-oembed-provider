require 'rest-client'
require 'json/ld'

##
# Provider for europeana.eu data item
#
# Example:
# http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212

Europeana::OEmbed.register do |source|

  re = %r{\Ahttp://data.europeana.eu/item/([0-9]+)/([^/]+)\z}

  def handleUrl(url)
    m = URI.parse(url).path.match(%r{/item/([^/]+)/([^/]+)})
    url = "#{ENV['API_URI']}/#{m[1]}/#{m[2]}.json-ld?wskey=#{ENV['API_KEY']}"
    begin
      response = RestClient::Request.execute(method: :get, url: url)
      json_ld = JSON.parse(response)
      puts json_ld.inspect
    rescue => e
      response = "GET #{url} => NOK (#{e.message})"
    end
    response
  end

  source.urls << re

  source.id = lambda { |url| handleUrl(url) }

  source.respond_with do |response|
    response.type = :rich
    response.version = '1.0'

    # Equals to “maxwidth”
    response.width = ENV['MAX_WIDTH']

    # Equals to “maxheight”
    response.height = ENV['MAX_HEIGHT']

    # It will contain an IFRAME HTML element with a “src” attribute set with a URL that points to
    # the service defined in Section 4.1 and with the “width” attribute (of the IFRAME) matching
    # the “maxwidth” of the request, and “height” matching “maxheight”.
    response.html = 'html'

    response.title = 'object.title'
    response.description = '1st value of object.proxies[.europeanaProxy=false].dcDescription'
    response.author_name = '1st value of object.aggregations[1].edmDataProvider'
    response.author_url = '1st value of object.aggregations[1].edmDataProvider'

    response.provider_name = 'Europeana'

    # Generate a Europeana Item URL with the following pattern:
    # https://www.europeana.eu/portal/{LANGUAGE}/record/%1/%2.html
    #
    # If no language parameter was supplied, generate a language-agnostic item URL:
    # https://www.europeana.eu/portal/record/%1/%2.html
    response.provider_url = 'https://www.europeana.eu/portal/{LANGUAGE}/record/%1/%2.html'

    # Get the URL of the image from “object.aggregations[1].isShownBy”, then look for the respective
    # web resource with the following JSON path expression and apply the additional logic below:
    # “object.aggregations[1].webResources[.about={IMAGE_URL}].webResourceEdmRights”
    # If no value exists get the default from: “object.aggregations[1].edmRights”
    response.rights_url = ''

    # If the URL matches pattern C) mentioned at the start of this Section, then check if there is one
    # “object.aggregations[1].hasView” that matches the URL specified as parameter (corresponding to the
    # matching group %3) otherwise choose the URL from “object.aggregations[1].edmObject”. For the other
    # patterns, also choose the URL from edm:object.
    #
    # If “maxwidth” is less than or equal to 200 then:
    # https://www.europeana.eu/api/v2/thumbnail-by-url.json?uri={MEDIA_URL}&size=w200
    #
    # If “maxwidth” is higher than 200:
    # https://www.europeana.eu/api/v2/thumbnail-by-url.json?uri={MEDIA_URL}&size=w400
    response.thumbnail_url = ''

    # Width of the thumbnail. If maxwidth <= 200, thumbnail_width = 200. If maxwidth > 200,
    # thumbnail_width = 400.
    response.thumbnail_width = 200

    # Omit for the time being. Noting here that in the future we might add height once we are able to store
    # and return the thumbnail dimension.
    # response.thumbnail_height = ?
  end
end

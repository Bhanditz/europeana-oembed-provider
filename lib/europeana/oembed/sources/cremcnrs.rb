##
# Provider for crem-cnrs.fr
#
# Example: http://archives.crem-cnrs.fr/archives/items/9798/
Europeana::OEmbed.register do |source|
  source.urls << %r{\Ahttp://archives.crem-cnrs.fr/archives/items/[^/]+/\z}

  source.id = lambda { |url| URI.parse(url).path.match(%r{/items/([^/]+)/})[1] }

  source.respond_with do |response|
    response.type = :rich
    response.html = 'http://archives.crem-cnrs.fr/archives/items/%{id}/player/346x130/'
    response.width = 361
    response.height = 250
    response.provider_name = 'CREM-CNRS'
    response.provider_url = 'http://crem-cnrs.fr/'
  end
end

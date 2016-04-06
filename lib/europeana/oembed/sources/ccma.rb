##
# Provider for ccma.cat
#
# Example: http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/
Europeana::OEmbed.register do |source|
  source.urls << 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/*/'

  source.id = lambda { |url| URI.parse(url).path.split('/')[-1] }

  source.respond_with do |response|
    response.type = :video
    response.html.builder = :iframe
    response.html.src = 'http://www.ccma.cat/video/embed/%{id}/'
    response.width = 500
    response.height = 281
  end
end

require 'test_helper'
require 'json'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_without_params
    get '/'
    assert last_response.not_found?
    assert_equal 'Not Found', last_response.body
  end

  def test_unknown_url
    get '/', url: 'http://www.example.com/'
    assert last_response.not_found?
    assert_equal 'Not Found', last_response.body
  end

  def test_ccma_url
    get '/', url: 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/'
    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 'video', json['type']
    assert_match %r{<iframe src="http://www.ccma.cat/video/embed/955989/"}, json['html']
  end

  def test_ina_url
    get '/', url: 'http://www.ina.fr/politique/elections-et-scrutins/video/CAB92011596/liste-daniel-hechter.fr.html#xtor=AL-3'
    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 'video', json['type']
    assert_match %r{<iframe .*src="https://player.ina.fr/player/embed/CAB92011596/}, json['html']
  end
end

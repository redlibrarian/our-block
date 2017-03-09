require "marc"
require "nokogiri"
require "open-uri"

class OURLimit

  attr_reader :sfx_data, :catkeys

  def initialize(options = {})
    @sfx_data = {}
    read_sfx_file(options[:sfx_file]) if options[:sfx_file]
  end

  def merged(catkey)
    "#{catkey},#{@catkeys[catkey]},#{@sfx_data[@catkeys[catkey]]}"
  end

  def report
    @catkeys.keys.each do |catkey|
      puts merged catkey
    end
  end

  def retrieve(oid)

    auth_notes = []
    Nokogiri::XML(open("https://resolver.library.ualberta.ca/resolver?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_ver=Z39.88-2004&rfr_id=info%3Asid%2Fualberta.ca%3Aopac&rft.genre=journal&rft.object_id=#{oid}&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004&sfx.response_type=simplexml").read).xpath("//authentication").each{|auth_note|
      auth_notes << auth_note.content }
    return auth_notes
  end

  def self.limit?(notes)
    notes.any?{|note| note.length >= 256}
  end

  def self.valid?(notes)
    notes.all?{|note| !(note =~ /<\/iframe>$/).nil? }
  end

  private

  def read_sfx_file(sfx_file)
    MARC::XMLReader.new(sfx_file).each{ |rec| @sfx_data[rec['022']['a']] = rec['090']['a'] if (rec['022'] and rec['090']) }
  end

end


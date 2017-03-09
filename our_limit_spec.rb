require 'webmock/rspec'
require_relative 'our_limit'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "https://resolver.library.ualberta.ca/resolver?ctx_enc=info:ofi/enc:UTF-8&ctx_ver=Z39.88-2004&rfr_id=info:sid/ualberta.ca:opac&rft.genre=journal&rft.object_id=954921332001&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&sfx.response_type=simplexml&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<sfx_menu><targets><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;&lt;/iframe&gt;</authentication></target></targets></sfx_menu>', :headers => {})

    stub_request(:get, "https://resolver.library.ualberta.ca/resolver?ctx_enc=info:ofi/enc:UTF-8&ctx_ver=Z39.88-2004&rfr_id=info:sid/ualberta.ca:opac&rft.genre=journal&rft.object_id=954921332002&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&sfx.response_type=simplexml&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<sfx_menu><targets><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;&lt;/iframe&gt;</authentication></target><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;&lt;/iframe&gt;</authentication></target><targets></sfx_menu>', :headers => {})


    stub_request(:get, "https://resolver.library.ualberta.ca/resolver?ctx_enc=info:ofi/enc:UTF-8&ctx_ver=Z39.88-2004&rfr_id=info:sid/ualberta.ca:opac&rft.genre=journal&rft.object_id=954921332003&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&sfx.response_type=simplexml&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<sfx_menu><targets><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Defaultxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;&lt;/iframe&gt;</authentication></target><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;</authentication></target><targets></sfx_menu>', :headers => {})

      stub_request(:get, "https://resolver.library.ualberta.ca/resolver?ctx_enc=info:ofi/enc:UTF-8&ctx_ver=Z39.88-2004&rfr_id=info:sid/ualberta.ca:opac&rft.genre=journal&rft.object_id=10920000000000121&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&sfx.response_type=simplexml&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
                 with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
                          to_return(:status => 200, :body => '<sfx_menu><targets><target><authentication>&lt;iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=THIS_TAG_SHOULD_MAKE_THE_ENTIRE_IFRAME_REALLY_TOO_LONG_THIS_TAG_SHOULD_MAKE_THE_ENTIRE_IFRAME_REALLY_TOO_LONG" width="100%" height="40" align="middle" frameborder="0" scrolling="no"&gt;&lt;p&gt;Your browser does not support iframes.&lt;/p&gt;</authentication></target></targets></sfx_menu>', :headers => {})



  end
end

#OUR block limit is 256 characters

describe OURLimit do

  before do
    @our_limit = OURLimit.new({sfx_file: "sfx_test_data.xml"})
  end

  describe "read SFX data file" do
    context "given an SFX data file" do
      it "should populate a hash of target-name -> object ID" do
        expect(@our_limit.sfx_data).to include("0168-0072" => "954921332001")
      end
    end
  end

  describe "make web services call" do
    context "given an SFX object ID" do
      it "should retrieve the authentication note field" do
        expect(@our_limit.retrieve("954921332001").first).to eq '<iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"><p>Your browser does not support iframes.</p></iframe>'
      end
    end

    it "should retrieve an array if there are multiple authentication note fields" do
        expect(@our_limit.retrieve("954921332002")).to eq ['<iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"><p>Your browser does not support iframes.</p></iframe>','<iframe src="http://tal.scholarsportal.info/alberta/sfx/?tag=Default" width="100%" height="40" align="middle" frameborder="0" scrolling="no"><p>Your browser does not support iframes.</p></iframe>']
    end
  end

  describe "check for length-limit" do
    context "given an authentication note" do
      it "should be less than 256 characters" do
        expect(OURLimit.limit?(@our_limit.retrieve("954921332001"))).to be false
        expect(OURLimit.limit?(@our_limit.retrieve("10920000000000121"))).to be true
        expect(OURLimit.limit?(@our_limit.retrieve("954921332002"))).to be false
        expect(OURLimit.limit?(@our_limit.retrieve("954921332003"))).to be true
      end
    end
  end

  describe "check for closing iframe tag" do
    context "given an authentication note" do
      it "should including a closing iframe tag" do
        expect(OURLimit.valid?(@our_limit.retrieve("954921332001"))).to be true
        expect(OURLimit.valid?(@our_limit.retrieve("10920000000000121"))).to be false
        expect(OURLimit.valid?(@our_limit.retrieve("954921332002"))).to be true
        expect(OURLimit.valid?(@our_limit.retrieve("954921332003"))).to be false
      end
    end
  end
end

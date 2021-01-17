class YunionYunionapi < Formula
  desc "Yunion Gateway Service"
  homepage "https://github.com/yunionio/onecloud.git"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git",
    :branch      => "master"
  
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "GOOS=darwin", "cmd/apigateway"
      bin.install "_output/bin/apigateway"
      prefix.install_metafiles
    end

    (buildpath/"yunionapi.conf").write yunionapi_conf
    etc.install "yunionapi.conf"
  end

  def post_install
    (var/"log/yunionapi").mkpath
  end

  def yunionapi_conf; <<~EOS
  region = 'Yunion'
  address = '0.0.0.0'
  port = 3000
  auth_uri = 'http://127.0.0.1:35357/v3'
  admin_user = 'sysadmin'
  admin_password = 'sysadmin'
  admin_tenant_name = 'system'
  enable_ssl = true
  ssl_certfile: /etc/yunion/pki/service.crt
  ssl_keyfile: /etc/yunion/pki/service.key
  EOS
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/apigateway</string>
        <string>--conf</string>
        <string>#{etc}/yunionapi.conf</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/yunionapi/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/yunionapi/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end

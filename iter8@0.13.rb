class Iter8AT013 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.13.2",
      revision: "1e636358b21fea10a804c7138d8230ed3007440c"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.13.2/iter8-darwin-amd64.tar.gz"
    sha256 "2e1466b069fd369378858c7390971618a16bdd18f6788595726f5c75313ac7d7"
  else
    depends_on "go" => :build
  end

  def install
    if OS.mac?
    else
      ENV["CGO_ENABLED"] = "0"

      ldflags = %W[
        -X github.com/iter8-tools/iter8/base.Version=v#{version}
        -X github.com/iter8-tools/iter8/cmd.gitCommit=#{Utils.git_head()}
      ]

      system "go", "build", *std_go_args(ldflags: ldflags), "-o", "iter8", "./"
    end
    bin.install "iter8"
  end

  test do
    system "#{bin}/iter8", "hub"
    assert File.directory? testpath/"charts/load-test-http/templates"
  end
end

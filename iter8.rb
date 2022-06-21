class Iter8 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.11.1",
      revision: "d3e149acf4d0f1c3451e804aea60c7cb991a0249"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.11.1/iter8-darwin-amd64.tar.gz"
    sha256 "c490da850b695a499fcb32e145c9cf121c6cd69ec68e915b401c6708ab8d5217"
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

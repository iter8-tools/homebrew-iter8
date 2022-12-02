class Iter8AT012 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.12.3",
      revision: "c891bca5deb188774fed8dd68312b5c1dd478750"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.12.3/iter8-darwin-amd64.tar.gz"
    sha256 "a7db46811dbee3268be733d117c138f8853f0ace70e348bf99baaf1394e93daf"
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

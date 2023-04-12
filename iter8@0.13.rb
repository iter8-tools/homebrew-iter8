class Iter8AT013 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.13.13",
      revision: "d1eb919218201aee396fb0a14cb8aed8be043566"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.13.13/iter8-darwin-amd64.tar.gz"
    sha256 "395eab8353f372c7fe428b1ccecb440cfb04fed4b278799bcfb1eb5703a7fc6f"
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

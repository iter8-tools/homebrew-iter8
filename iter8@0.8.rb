class Iter8AT08 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.8.30",
      revision: "499b2297c5b328e65e8b30c007790ef08bfce335"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.8.30/iter8-darwin-amd64.tar.gz"
    sha256 "44e85039928cd1fc223dff7203b42c39d8dbf5ea271c755081f2e66ff33f124c"
  else
    depends_on "go" => :build
  end

  def install
    if OS.mac?
    else
      ENV["CGO_ENABLED"] = "0"

      ldflags = %W[
        -X github.com/iter8-tools/iter8/basecli.version=v#{version}
        -X github.com/iter8-tools/iter8/basecli.gitCommit=#{Utils.git_head()}
        -X github.com/iter8-tools/iter8/basecli.gitTreeState=clean
      ]

      system "go", "build", *std_go_args(ldflags: ldflags), "-o", "iter8", "./"
    end
    bin.install "iter8"
  end

  test do
    system "#{bin}/iter8", "hub", "-e", "load-test"
    assert File.directory? testpath/"load-test/templates"

    version_output = shell_output(bin/"iter8 version 2>&1")
    assert_match "GitTreeState:\"clean\"", version_output
    if build.stable?
      revision = stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision]
      assert_match "GitCommit:\"#{revision}\"", version_output
      assert_match "Version:\"v#{version}\"", version_output
    end
  end
end

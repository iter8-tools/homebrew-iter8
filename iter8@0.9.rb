class Iter8AT09 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.9.0",
      revision: "ac88e759387efada4bf2aa2adef84bcf5a04fe09"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.9.0/iter8-darwin-amd64.tar.gz"
    sha256 "2205f7714cccefc5d04bda1aaa6bc5f1df0a28c011bef92a642cdcbcd721dae1"
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

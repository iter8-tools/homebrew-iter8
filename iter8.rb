class Iter8 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "refs/tags/v0.8.19",
      revision: "67dd38360f766de6077a11a6e47c0a54152ec94d"
  license "Apache-2.0"
  head "https://github.com/iter8-tools/iter8.git", branch: "master"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/refs/tags/v0.8.19/iter8-darwin-amd64.tar.gz"
    sha256 "3b1ce9e93723d698b1fa559478f03e092b57513ee6bf63d6cb7c3c4a22ba4b91"
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

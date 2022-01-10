class Iter8 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "${VERSION}",
      revision: "${REVISION}"
  license "Apache-2.0"
  head "https://github.com/iter8-tools/iter8.git", branch: "master"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"

    ldflags = %W[
      -X github.com/iter8-tools/iter8/basecli.version=v#{version}
      -X github.com/iter8-tools/iter8/basecli.gitCommit=#{Utils.git_head()}
      -X github.com/iter8-tools/iter8/basecli.gitTreeState=clean
    ]

    system "go", "build", *std_go_args(ldflags: ldflags), "-o", "bin/iter8", "./"
    bin.install "bin/iter8"
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
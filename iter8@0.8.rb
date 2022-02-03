class Iter8AT08 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.8.31",
      revision: "120f5e62865b4bbf07d4bdec8a59dd23abc36bc8"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.8.31/iter8-darwin-amd64.tar.gz"
    sha256 "8fd39a97f5063e099a34bbe4797a12da71b3bfe4eff301a06a96634f871e908d"
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

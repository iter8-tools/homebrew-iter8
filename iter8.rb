class Iter8 < Formula
  desc "Kubernetes release engineering"
  homepage "https://iter8.tools"
  url "https://github.com/iter8-tools/iter8.git",
      tag:      "v0.13.0",
      revision: "5c18637ccb33050b7a87f19b3e43ca6d74ac9405"
  license "Apache-2.0"

  if OS.mac?
    url "https://github.com/iter8-tools/iter8/releases/download/v0.13.0/iter8-darwin-amd64.tar.gz"
    sha256 "16189bb77f60d53f5aa6f6af54554e68632c66b0f4dbc20554e3da5f0888b060"
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

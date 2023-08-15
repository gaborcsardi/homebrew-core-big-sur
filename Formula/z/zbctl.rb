class Zbctl < Formula
  desc "Zeebe CLI client"
  homepage "https://docs.camunda.io/docs/apis-clients/cli-client/index/"
  url "https://github.com/camunda/zeebe.git",
      tag:      "8.2.11",
      revision: "322d1e5f7705059c541e0c72a64f7f0f14cbbcb0"
  license "Apache-2.0"
  head "https://github.com/camunda/zeebe.git", branch: "develop"

  # Upstream creates stable version tags (e.g., `v1.2.3`) before a release but
  # the version isn't considered to be released until a corresponding release
  # is created on GitHub, so it's necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "bbd4fdc06d751e3b7df6bb3baa2a9bc1bcc6772eba00424b652f8736f0227fe1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "bbd4fdc06d751e3b7df6bb3baa2a9bc1bcc6772eba00424b652f8736f0227fe1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "bbd4fdc06d751e3b7df6bb3baa2a9bc1bcc6772eba00424b652f8736f0227fe1"
    sha256 cellar: :any_skip_relocation, ventura:        "fc61057bc6f0c901fe82abeb8c2f25cfbde78cb1cc88ab1ff839621d8d8c2a2e"
    sha256 cellar: :any_skip_relocation, monterey:       "fc61057bc6f0c901fe82abeb8c2f25cfbde78cb1cc88ab1ff839621d8d8c2a2e"
    sha256 cellar: :any_skip_relocation, big_sur:        "fc61057bc6f0c901fe82abeb8c2f25cfbde78cb1cc88ab1ff839621d8d8c2a2e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6455ec1e5b12de3d587e7bcaea69d2c7db3c7545e20a829a6ee6c8af1f0baa5c"
  end

  depends_on "go" => :build

  def install
    commit = Utils.git_short_head
    chdir "clients/go/cmd/zbctl" do
      project = "github.com/camunda/zeebe/clients/go/v8/cmd/zbctl/internal/commands"
      ldflags = %W[
        -w
        -X #{project}.Version=#{version}
        -X #{project}.Commit=#{commit}
      ]
      system "go", "build", "-tags", "netgo", *std_go_args(ldflags: ldflags)

      generate_completions_from_executable(bin/"zbctl", "completion")
    end
  end

  test do
    # Check status for a nonexistent cluster
    status_error_message =
      "Error: rpc error: code = " \
      "Unavailable desc = connection error: " \
      "desc = \"transport: Error while dialing: dial tcp 127.0.0.1:26500: connect: connection refused\""
    output = shell_output("#{bin}/zbctl status 2>&1", 1)
    assert_match status_error_message, output
    # Check version
    commit = stable.specs[:revision][0..7]
    expected_version = "zbctl #{version} (commit: #{commit})"
    assert_match expected_version, shell_output("#{bin}/zbctl version")
  end
end
require "test_helper"
require "tmpdir"

class AssetManifestTest < ActiveSupport::TestCase
  test "reads compiled assets from a saved manifest" do
    Dir.mktmpdir do |directory|
      path = File.join(directory, "manifest.json")
      File.write(path, '{"assets":{"application.css":"application-digest.css"}}')

      manifest = Sprockets::Manifest.new(path)

      assert_equal "application-digest.css", manifest.assets["application.css"]
    end
  end
end

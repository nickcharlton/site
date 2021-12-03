require "rspec"

require "jekyll"

TEST_DIR = File.dirname(__FILE__)
TMP_DIR  = File.expand_path("../tmp", TEST_DIR)

def tmp_dir(*files)
  File.join(TMP_DIR, *files)
end

def source_dir(*files)
  tmp_dir("source", *files)
end

def dest_dir(*files)
  tmp_dir("dest", *files)
end

def build_site(opts = {})
  defaults = Jekyll::Configuration::DEFAULTS
  opts = opts.merge(
    source: source_dir,
    destination: dest_dir
  )
  conf = Jekyll::Utils.deep_merge_hashes(defaults, opts)
  Jekyll::Site.new(conf)
end

def collection(site, label = "test")
  Jekyll::Collection.new(site, label)
end

def build_doc(opts = {})
  site = build_site(opts)
  options = { site: site, collection: collection(site) }
  doc = Jekyll::Document.new(source_dir("_test/doc.md"), options)
  doc.merge_data!({ author: "test" })
  doc
end

def render(content)
  doc = build_doc
  doc.content = content
  doc.output = Jekyll::Renderer.new(doc.site, doc).run
end

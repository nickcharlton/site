require "spec_helper"
require_relative "../_plugins/filter_posts"

RSpec.describe Jekyll::FilterPosts do
  include Jekyll::FilterPosts

  describe "tags" do
    it "can filter by presence of tags" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "includes 'week-notes'")

      expect(posts).to match_array([document1])
    end

    it "can filter by exclusion of tags" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "excludes 'week-notes'")

      expect(posts).to match_array([document2])
    end

    it "is empty if the filter method is invalid" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "something 'week-notes'")

      expect(posts).to match_array([])
    end
  end
end

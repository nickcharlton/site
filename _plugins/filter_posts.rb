module Jekyll
  module FilterPosts
    def filter_posts(posts, attribute, expression)
      method_name, key = expression.scan(/(\w*)\s?'([\w-]*)?'/).first

      method = case method_name
               when "includes"
                 :select
               when "excludes"
                 :reject
               else
                 nil
               end

      return [] unless method

      posts.send(method) { |post| post.data[attribute].include?(key) }
    end
  end
end

Liquid::Template.register_filter(Jekyll::FilterPosts)

FactoryBot.define do
  factory :post do
    title { "MyString" }
    content { "MyText" }
    posted_date { "2025-03-26 06:44:29" }
    view_count { 1 }
    author_name { "MyString" }
    author_id { "MyString" }
    author_email { "MyString" }
    cid { "MyString" }
    gid { "MyString" }
    bid { "MyString" }
    is_notice { false }
    attachment_urls { "MyText" }
    attachment_names { "MyText" }
    source_url { "MyString" }
    scraped_at { "2025-03-26 06:44:29" }
    last_updated_at { "2025-03-26 06:44:29" }
  end
end

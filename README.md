rss2slack
===============

# これは何？

rssをslackのチャンネルに流すやつ

# 使い方

    bundle install
    bundle exec ./rss.rb

db/db.sqlite3に最終取得日を保存しているので、同じ記事が配信されることは無いです
cronか何かで定期的に実行すればいいと思います

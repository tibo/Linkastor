require "rails_helper"

describe CustomSources::Rss, vcr: true do
  describe "import" do
    it "reads product hunt feed" do
      rss = FactoryGirl.create(:rss)
      rss.extra["url"] = "http://www.producthunt.com/feed"
      rss.import
      rss.links.count.should == 45
    end
    
    it "saves url and content" do
      rss = FactoryGirl.create(:rss)
      rss.extra["url"] = "http://www.producthunt.com/feed"
      rss.import
      link = rss.links.first
      link.url.should == "http://www.producthunt.com/r/4570ddb30433f0/25610?app_id=339"
      link.title.should == "<content lang=\"en-US\"\n  type=\"html\">      &lt;p&gt;\n        &amp;#8220;\n        Apparently from some of the minds being the hilariously awesome Octodad: http://www.producthunt.com/posts/octodad-dadliest-catch\n        &amp;#8221;\n        &lt;br&gt;\n        – Kris\n      &lt;/p&gt;\n      &lt;p&gt;\n        &lt;a href=&quot;http://www.producthunt.com/games/antbassador?utm_campaign=producthunt-atom-posts-feed&amp;amp;utm_medium=rss-feed&amp;amp;utm_source=producthunt-atom-posts-feed&quot;&gt;Discussion&lt;/a&gt;\n        |\n        &lt;a href=&quot;http://www.producthunt.com/r/4570ddb30433f0/25610?app_id=339&quot;&gt;Link&lt;/a&gt;\n      &lt;/p&gt;\n</content>"
    end
  end
end
FactoryGirl.define do
  factory :invite do
    referrer { FactoryGirl.create(:user).id }
    group
    email        {|n| "string#{n}@example.com" }
    code        "string"
    accepted    false
  end
end
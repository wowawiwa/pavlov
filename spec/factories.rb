FactoryGirl.define do

  factory :user do
    sequence(:name)       {|n| "Example user#{n}"}
    email                 { "#{name.gsub(/\s/, '.')}@example.com"}
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :list do
    sequence(:name)       {|n| "Example list#{n}"}
    user
  end

  factory :word do
    content   "Example content"
    tip       "Example tip"
  end

  # TODO ! 
  # - work with create but probably not with build
  # - does not work with create(:card, user: a_user)
  factory :card do
    list
    user      { list.user }
    after(:build) do |c|
      c.user.build_card( build(:word), c.list , c)
    end
    #association :evaluable, factory: :word#, strategy: :build
  end

  # TODO Validation failed: Card has already been taken
  factory :card_meta do
    association :card, factory: :card
  end

  factory :evaluation do
    result    false
    association :card, factory: :card
  end
end

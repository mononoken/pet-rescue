FactoryBot.define do
  factory :staff_account do
    organization { ActsAsTenant.current_tenant }
    user { association :user, organization: organization }
    deactivated_at { nil }

    trait :deactivated do
      deactivated_at { DateTime.now }
    end

    trait :admin do
      after(:build) do |_account, context|
        context.user.add_role(:admin, context.organization)
      end
    end

    after(:build) do |_account, context|
      context.user.add_role(:staff, context.organization)
    end
  end
end

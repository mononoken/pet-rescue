FactoryBot.define do
  factory :pet do
    application_paused { false }
    birth_date { Faker::Date.backward(days: 7) }
    breed { Faker::Creature::Dog.breed }
    description { Faker::Lorem.sentence }
    name { Faker::Creature::Dog.name }
    placement_type { Faker::Number.within(range: 0..2) }
    published { true }
    sex { Faker::Creature::Dog.gender }
    species { Faker::Number.within(range: 0..1) }
    weight_from { 10 }
    weight_to { 20 }
    weight_unit { "lb" }

    trait :adoption_pending do
      adopter_applications { build_list(:adopter_application, 3, :adoption_pending) }
    end

    trait :adopted do
      match { association :match }
    end
  end
end
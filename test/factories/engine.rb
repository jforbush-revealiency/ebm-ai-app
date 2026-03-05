FactoryGirl.define do
  factory :cat_electric_engine, class: Engine do
    code "3512B-EUI"

    association :manufacturer, factory: :manufacturer, code: "Cat"
    association :drive_type, factory: :drive_type, code: "Electric"
  end

  factory :cat_mechanical_engine, class: Engine do
    code "DMC00135"

    association :manufacturer, factory: :manufacturer, code: "Cat"
    association :drive_type, factory: :drive_type, code: "Mechanical"
  end

  factory :cummins_electric_engine, class: Engine do
    code "3512B-EUI"

    association :manufacturer, factory: :manufacturer, code: "Cummins"
    association :drive_type, factory: :drive_type, code: "Electric"
  end

  factory :cummins_mechanical_engine, class: Engine do
    code "DMC00135"

    association :manufacturer, factory: :manufacturer, code: "Cummins"
    association :drive_type, factory: :drive_type, code: "Mechanical"
  end

  factory :cat_single_stack, class: Engine do
    code "SingleStack"
    is_single_stack true

    association :manufacturer, factory: :manufacturer, code: "Cat"
    association :drive_type, factory: :drive_type, code: "Electric"
  end
end


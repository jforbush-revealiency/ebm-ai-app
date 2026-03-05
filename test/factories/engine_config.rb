FactoryGirl.define do
  factory :cat_electric_config_1, class: EngineConfig do
    code "151-4787"
    co2_percent 0.10
    co 90
    nox 380

    association :engine, factory: :cat_electric_engine, code: "3512B-EUI"
  end

  factory :cat_mechanical_config_1, class: EngineConfig do
    code "338-9720"
    co2_percent 0.10
    co 90
    nox 380

    association :engine, factory: :cat_mechanical_engine, code: "3512C-HD"
  end

  factory :cat_single_stack_config_1, class: EngineConfig do
    code "SingleSingle"
    co2_percent 0.10
    co 90
    nox 380
    rated_rpm 1900
    rated_hp 1900

    association :engine, factory: :cat_single_stack, code: "SingleStack"
  end
end


FactoryGirl.define do
  factory :vehicle_cat_electic_attainment, class: Vehicle do
    code "MD702"
    model_number "785C"
    serial_number "5AZ00087"

    association :engine_config, factory: :cat_electric_config_1, code: "151-4785"
    association :location, factory: :location_attainment, code: "Attainment"
  end

  factory :vehicle_cat_electic_non_attainment, class: Vehicle do
    code "MD704"
    model_number "785C"
    serial_number "5AZ00089"

    association :engine_config, factory: :cat_electric_config_1, code: "151-4785"
    association :location, factory: :location_non_attainment, code: "Non Attainment"
  end

  factory :vehicle_cat_mechanical_1_attainment, class: Vehicle do
    code "V80"
    model_number "785D"
    serial_number "DMC00135"

    association :engine_config, factory: :cat_mechanical_config_1, code: "338-9720"
    association :location, factory: :location_attainment, code: "Attainment"
  end

  factory :vehicle_cat_mechanical_2_non_attainment, class: Vehicle do
    code "V81"
    model_number "785D"
    serial_number "MSY00637"

    association :engine_config, factory: :cat_mechanical_config_1, code: "285-0785"
    association :location, factory: :location_non_attainment, code: "Non Attainment"
  end

  factory :vehicle_cat_single_stack, class: Vehicle do
    code "SingleStack"
    model_number "SingleStack"
    serial_number "SingleStack"

    association :engine_config, factory: :cat_single_stack_config_1, code: "SingleStack"
    association :location, factory: :location_attainment, code: "Attainment"
  end
end


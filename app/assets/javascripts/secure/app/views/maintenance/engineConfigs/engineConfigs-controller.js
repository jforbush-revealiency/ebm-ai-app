/**
 * The engineConfigs page
 *
 * Type: Controller
 *
 * ID: engineConfigsController
 *
 */

(function () {
  'use strict';

  angular.module('engineConfigs').controller('engineConfigsController',
      [
        '$scope',
        'engineApiService',
        'messageBoxService',
        'engineConfigApiService',
        function($scope, engineApiService, messageBoxService, engineConfigApiService) {
          var viewModel = {
            allData: [],
            allEngines: [],
            id: null,
            code: null,
            description: null,
            selectedEngine: null,
            selectedData: null,
            co_percent: null,
            co2PlusO2Percent: null,
            testPercentLoad: null,
            testRpm: null,
            testBoostPsi: null,
            testFuelGallonsPerHour: null,
            co: null,
            nox: null,
            ratedRPM: null,
            ratedHP: null,
            isRealValues: false,
            search: '',
            showForm: false,
            formTitle: 'Add'
          };

          //------------------------------------
          // initScope
          //------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;
            
            // Functions
            $scope.save = save;
            $scope.clear = clear;
            $scope.remove = remove;
            $scope.openForm = openForm;
            $scope.onDataSelected = onDataSelected;

            // Get Data
            engineConfigApiService.getAll().$promise.then(onDataLoaded);
            engineApiService.getAll().$promise.then(onEnginesLoaded);
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData.length = 0;
            _.each(data, function(row) {
              convertToNumbers(row);
              viewModel.allData.push(row);
            });
          }

          //------------------------------------
          // onEnginesLoaded
          //------------------------------------
          function onEnginesLoaded(data) {
            viewModel.allEngines = data;
          }

          //------------------------------------
          // onDataSelected
          //------------------------------------
          function onDataSelected(data) {
            if (data.selected) {
              viewModel.selectedData = data;
              viewModel.code = data.code;
              viewModel.description = data.description;
              viewModel.co2_percent = data.co2_percent;
              viewModel.co = data.co;
              viewModel.nox = data.nox;
              viewModel.ratedRPM = data.rated_rpm;
              viewModel.ratedHP = data.rated_hp;
              viewModel.co2PlusO2Percent = data.co2_plus_o2_percent;
              viewModel.testPercentLoad = data.test_percent_load;
              viewModel.testRpm = data.test_rpm;
              viewModel.testBoostPsi = data.test_boost_psi;
              viewModel.testFuelGallonsPerHour = data.test_fuel_gallons_per_hour;
              viewModel.isRealValues = data.is_real_values;

              viewModel.selectedEngine = _.findWhere(viewModel.allEngines, 
                                                           {id: data.engine_id});

              viewModel.showForm = true;
              viewModel.formTitle = 'Edit';
            }
          }

          //------------------------------------
          // openForm
          //------------------------------------
          function openForm() {
            viewModel.showForm = true;
            clear(true);
          }

          //------------------------------------
          // clear
          //------------------------------------
          function clear(leaveFormOpen) {
            viewModel.code = null;
            viewModel.description = null;
            viewModel.co2_percent = null;
            viewModel.co = null;
            viewModel.nox = null;
            viewModel.ratedRPM = null;
            viewModel.ratedHP = null;
            viewModel.selectedEngine = null;
            viewModel.co2PlusO2Percent = null;
            viewModel.testPercentLoad = null;
            viewModel.testRpm = null;
            viewModel.testBoostPsi = null;
            viewModel.testFuelGallonsPerHour = null; 
            viewModel.isRealValues = false;

            if (viewModel.selectedData) {
              viewModel.selectedData.selected = false;
            }

            viewModel.selectedData = null;
            viewModel.showForm = !!leaveFormOpen;
            viewModel.formTitle = 'Add';

            $scope.form.$setPristine();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save() {
            if ($scope.form.$invalid) {
              messageBoxService.show('md',
                                     'Errors were detected',
                                     'Please correct the errors and try again.',
                                     'OK');
              return;
            }

            var data = {
              data: {
                attributes: {
                  code: viewModel.code,
                  description: viewModel.description,
                  co2_percent: viewModel.co2_percent,
                  co: viewModel.co,
                  nox: viewModel.nox,
                  rated_rpm: viewModel.ratedRPM,
                  rated_hp: viewModel.ratedHP,
                  co2_plus_o2_percent: viewModel.co2PlusO2Percent,
                  test_percent_load: viewModel.testPercentLoad,
                  test_rpm: viewModel.testRpm,
                  test_boost_psi: viewModel.testBoostPsi,
                  test_fuel_gallons_per_hour: viewModel.testFuelGallonsPerHour,
                  is_real_values: viewModel.isRealValues, 
                  engine_id: viewModel.selectedEngine.id
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
            }

            engineConfigApiService.save(data).then(function(data) {
              convertToNumbers(data);
              if (viewModel.selectedData) {
                var currentData = _.findWhere(viewModel.allData, {id: data.id});
                if (currentData) {
                  _.extend(currentData, data);
                }
              } else {
                viewModel.allData.push(data);
              }
              clear();
            });
          }
          //------------------------------------
          // convertToNumbers
          //------------------------------------
          function convertToNumbers(data) {
            data.co2_percent = Number(data.co2_percent);
            data.co = Number(data.co);
            data.nox = Number(data.nox);
            data.rated_rpm = Number(data.rated_rpm);
            data.rated_hp = Number(data.rated_hp);
            data.co2_plus_o2_percent = data.co2_plus_o2_percent ? Number(data.co2_plus_o2_percent) : null;
            data.test_percent_load = data.test_percent_load ? Number(data.test_percent_load) : null;
            data.test_rpm = data.test_rpm ? Number(data.test_rpm) : null;
            data.test_boost_psi = data.test_boost_psi ? Number(data.test_boost_psi) : null;
            data.test_fuel_gallons_per_hour = data.test_fuel_gallons_per_hour ? Number(data.test_fuel_gallons_per_hour) : null;
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove() {
            if (viewModel.selectedData) {
              engineConfigApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          initScope();

        }
      ]);
})();

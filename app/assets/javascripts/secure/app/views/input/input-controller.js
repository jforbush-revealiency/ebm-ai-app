/** 
 * The input page
 * 
 * Type: Controller
 * 
 * ID: inputController
 * 
 */
(function () {
    'use strict';

    angular.module('input').controller('inputController',
        [
        '$scope',
        '$location',
        '$routeParams',
        'inputApiService',
        'messageBoxService',
        'companyApiService',
        'vehicleApiService',
        'currentUserApiService',
        function ($scope, $location, $routeParams, inputApiService, messageBoxService, 
                  companyApiService, vehicleApiService, currentUserApiService) {

            var viewModel = {
              allLocations: [],
              allVehicles: [],
              allHasEngineCodes: [],
              allHasLatestConfigurationFile: [],

              selectedLocation: null,
              selectedVehicle: null,
              selectedHasEngineCodes: null,
              isSingleStack: false,

              engine_hours: null,
              engine_rpm: null,
              alternator_rpm: null,
              engine_hp: null,
              alternator_hp: null,
              left_bank_co2_percent: null,
              left_bank_co: null,
              left_bank_nox: null,
              right_bank_co2_percent: null,
              right_bank_co: null,
              right_bank_nox: null,
              input_id: null
            };

            //----------------------------------------------
            // initScope
            //----------------------------------------------
            function initScope() {
              // Properties
              $scope.viewModel = viewModel;

              // Functions
              $scope.save = save;
              $scope.cancel = cancel;
              $scope.onVehicleChange = onVehicleChange;
              $scope.onLocationChange = onLocationChange;
              $scope.onHasEngineCodesChange = onHasEngineCodesChange;
              $scope.onHasLatestConfigurationFileChange = onHasLatestConfigurationFileChange;

              // Get Data
              setHasEngineCodes();
              setHasLatestConfigurationFile();
              currentUserApiService.getCurrentUser().$promise.then(onCurrentUserLoaded);
            }

            //----------------------------------------------
            // setHasEngineCodes
            //----------------------------------------------
            function setHasEngineCodes() {
              viewModel.allHasEngineCodes.length = 0;
              viewModel.allHasEngineCodes.push({code: 'Yes', value: true});
              viewModel.allHasEngineCodes.push({code: 'No', value: false});
            }

            //----------------------------------------------
            // setHasLatestConfigurationFile
            //----------------------------------------------
            function setHasLatestConfigurationFile() {
              viewModel.allHasLatestConfigurationFile.length = 0;
              viewModel.allHasLatestConfigurationFile.push({code: 'Yes', value: 'Yes'});
              viewModel.allHasLatestConfigurationFile.push({code: 'No', value: 'No'});
              viewModel.allHasLatestConfigurationFile.push({code: 'N/A', value: 'N/A'});
            }

            //----------------------------------------------
            // onCurrentUserLoaded
            //----------------------------------------------
            function onCurrentUserLoaded(data) {
              // This is restricted by the current users's access on the server side
              companyApiService.getAllLocations().$promise.then(onLocationsLoaded);
            }

            //----------------------------------------------
            // onInputLoaded
            //----------------------------------------------
            function onInputLoaded(data) {
              // This is loaded after the locations have been loaded
              var location = _.findWhere(viewModel.allLocations, {id: data.location_id});
              onLocationChange(location, data.vehicle_id);
              onHasEngineCodesChange(_.findWhere(viewModel.allHasEngineCodes, {value: data.has_engine_codes}));
              onHasLatestConfigurationFileChange(_.findWhere(viewModel.allHasLatestConfigurationFile, {value: data.has_latest_configuration_file}));
              viewModel.engine_hours = Number(data.engine_hours);
              viewModel.engine_rpm = Number(data.engine_rpm);
              viewModel.engine_hp = Number(data.engine_hp);
              viewModel.alternator_rpm = Number(data.alternator_rpm);
              viewModel.alternator_hp = Number(data.alternator_hp);
              viewModel.left_bank_co2_percent = Number(data.left_bank_co2_percent);
              viewModel.left_bank_co = Number(data.left_bank_co);
              viewModel.left_bank_nox = Number(data.left_bank_nox);
              viewModel.right_bank_co2_percent = Number(data.right_bank_co2_percent);
              viewModel.right_bank_co = Number(data.right_bank_co);
              viewModel.right_bank_nox = Number(data.right_bank_nox);
              viewModel.input_id = data.id;
            }

            //----------------------------------------------
            // onLocationsLoaded
            //----------------------------------------------
            function onLocationsLoaded(data) {
              viewModel.allLocations = data;

              if (viewModel.allLocations.length === 1) {
                onLocationChange(data[0]);
              }

              if ($routeParams.id) {
                inputApiService.getInput($routeParams.id).$promise.then(onInputLoaded);
              }
            }

            //----------------------------------------------
            // onVehiclesLoaded
            //----------------------------------------------
            function onVehiclesLoaded(data, vehicleId) {
              viewModel.allVehicles = data;
              if (data.length === 0) {
                viewModel.selectedVehicle = null;
                messageBoxService.show('md',
                                       'No Vehicles',
                                       'There are no vehicles associated with this location.  Please contact support.',
                                       'OK');
                return;
              }

              if (vehicleId) {
                onVehicleChange(_.findWhere(viewModel.allVehicles, {id: vehicleId}));
              }
            }

          //------------------------------------
          // onLocationChange
          //------------------------------------
          function onLocationChange(location, vehicleId) {
            viewModel.selectedLocation = location;
            var locationId = viewModel.selectedLocation.id;
            vehicleApiService.getVehiclesByLocation(locationId).$promise.then(function(data) {
              onVehiclesLoaded(data, vehicleId);
            });
          }

          //------------------------------------
          // onVehicleChange
          //------------------------------------
          function onVehicleChange(vehicle) {
            viewModel.selectedVehicle = vehicle;
            viewModel.isSingleStack = false;
            if (viewModel.selectedVehicle && viewModel.selectedVehicle.drive_type === 'Mechanical') {
              viewModel.alternator_rpm = null;
              viewModel.alternator_hp = null;
            }
            if (viewModel.selectedVehicle) {
              viewModel.isSingleStack = viewModel.selectedVehicle.is_single_stack === 'true';
            }
          }

          //------------------------------------
          // onHasEngineCodesChange
          //------------------------------------
          function onHasEngineCodesChange(hasEngineCodes) {
            viewModel.selectedHasEngineCodes = hasEngineCodes;
            checkEngineCodes();
          }

          //------------------------------------
          // onHasLatestConfigurationFileChange
          //------------------------------------
          function onHasLatestConfigurationFileChange(hasLatestConfigurationFile) {
            viewModel.selectedHasLatestConfigurationFile = hasLatestConfigurationFile;
            checkLatestConfigurationFile();
          }

          //------------------------------------
          // checkEngineCodes 
          //------------------------------------
          function checkEngineCodes() {
            if (viewModel.selectedHasEngineCodes && viewModel.selectedHasEngineCodes.value) {
              messageBoxService.show('md',
                                     'Engine Codes',
                                     'Please correct the engine codes before continuing.',
                                     'OK');
              return false;
            }
            return true;
          }

          //------------------------------------
          // checkLatestConfigurationFile 
          //------------------------------------
          function checkLatestConfigurationFile() {
            if (viewModel.selectedHasLatestConfigurationFile && viewModel.selectedHasLatestConfigurationFile.value === 'No') {
              messageBoxService.show('md',
                                     'Latest Configuration File',
                                     'Please install the latest engine configuration file for the vehicle before continuing.',
                                     'OK');
              return false;
            }
            return true;
          }

          //----------------------------------------------
          // cancel
          //----------------------------------------------
          function cancel() {
          }

          //----------------------------------------------
          // clear
          //----------------------------------------------
          function clear() {
            viewModel.selectedLocation = null;
            viewModel.selectedVehicle = null;
            viewModel.selectedHasEngineCodes = null;
            viewModel.engine_hours = null;
            viewModel.engine_rpm = null;
            viewModel.alternator_rpm = null;
            viewModel.engine_hp = null;
            viewModel.alternator_hp = null;
            viewModel.left_bank_co2_percent = null;
            viewModel.left_bank_co = null;
            viewModel.left_bank_nox = null;
            viewModel.right_bank_co2_percent = null;
            viewModel.right_bank_co = null;
            viewModel.right_bank_nox = null;
            viewModel.input_id = null;

            if (viewModel.allLocations.length === 1) {
              onLocationChange(viewModel.allLocations[0]);
            }

            $scope.form.$setPristine();

          }

          //----------------------------------------------
          // save
          //----------------------------------------------
          function save() {
            if ($scope.form.$invalid) {
              messageBoxService.show('md',
                                     'Errors were detected',
                                     'Please correct the errors and try again.',
                                     'OK');
              return;
            }

            if (checkEngineCodes() && checkLatestConfigurationFile()) {
              var data = {
                data: {
                  attributes: {
                    location_id: viewModel.selectedLocation.id,
                    vehicle_id: viewModel.selectedVehicle.id,
                    has_engine_codes: viewModel.selectedHasEngineCodes.value,
                    has_latest_configuration_file: viewModel.selectedHasLatestConfigurationFile.value,
                    engine_hours: viewModel.engine_hours,
                    engine_rpm: viewModel.engine_rpm,
                    alternator_rpm: viewModel.alternator_rpm,
                    engine_hp: viewModel.engine_hp,
                    alternator_hp: viewModel.alternator_hp,
                    left_bank_co2_percent: viewModel.left_bank_co2_percent,
                    left_bank_co: viewModel.left_bank_co,
                    left_bank_nox: viewModel.left_bank_nox,
                    right_bank_co2_percent: viewModel.right_bank_co2_percent,
                    right_bank_co: viewModel.right_bank_co,
                    right_bank_nox: viewModel.right_bank_nox
                  }
                }
              };

              if (viewModel.input_id) {
                data.data.id = viewModel.input_id;
              }

              inputApiService.save(data).then(function(data) {
                messageBoxService.show('md',
                                       'Successfully submitted',
                                       'Your input has been successfully submitted and will be processed shortly.',
                                       'OK').result.then(function(button) {
                                          clear();
                                          $location.path("/reports/find-input");
                                       });
              });
            }
          }

          initScope();
        }]);
})();

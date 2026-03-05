/**
 * The vehicles page
 *
 * Type: Controller
 *
 * ID: vehiclesController
 *
 */

(function () {
  'use strict';

  angular.module('vehicles').controller('vehiclesController',
      [
        '$scope',
        'messageBoxService',
        'companyApiService',
        'vehicleApiService',
        'engineConfigApiService',
        function($scope, messageBoxService, companyApiService, vehicleApiService, engineConfigApiService) {
          var viewModel = {
            allData: [],
            allEngineConfigs: [],
            allCompanies: [],
            allLocations: [],
            displayData: [],
            id: null,
            code: null,
            description: null,
            modelNumber: null,
            estimatedAnnualVehicleHours: null,
            telematic: false,
            serialNumber: null,
            folderCode: null,
            selectedCompany: null,
            selectedLocation: null,
            selectedEngineConfig: null,
            selectedData: null,
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
            $scope.onCompanyChange = onCompanyChange;

            // Get Data
            engineConfigApiService.getAll().$promise.then(onEngineConfigsLoaded);
            companyApiService.getAll().$promise.then(onCompaniesLoaded);
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData = data;
          }

          //------------------------------------
          // onEngineConfigsLoaded
          //------------------------------------
          function onEngineConfigsLoaded(data) {
            viewModel.allEngineConfigs = data;
          }

          //------------------------------------
          // onLocationsLoaded
          //------------------------------------
          function onLocationsLoaded(data) {
            viewModel.allLocations = data;
          }

          //------------------------------------
          // onCompaniesLoaded
          //------------------------------------
          function onCompaniesLoaded(data) {
            viewModel.allCompanies = data;
          }

          //------------------------------------
          // onDataSelected
          //------------------------------------
          function onDataSelected(data) {
            if (data.selected) {
              viewModel.selectedData = data;
              viewModel.code = data.code;
              viewModel.description = data.description;
              viewModel.modelNumber = data.model_number;
              viewModel.serialNumber = data.serial_number;
              viewModel.telematic = data.telematic;
              viewModel.estimatedAnnualVehicleHours = data.estimated_annual_vehicle_hours ? Number(data.estimated_annual_vehicle_hours) : null;
              viewModel.folderCode = data.folder_code;

              viewModel.selectedEngineConfig = _.findWhere(viewModel.allEngineConfigs, 
                                                           {id: data.engine_config_id});

              viewModel.selectedLocation = _.findWhere(viewModel.allLocations, 
                                                           {id: data.location_id});

              viewModel.showForm = true;
              viewModel.formTitle = 'Edit';
            }
          }

          //------------------------------------
          // onCompanyChange
          //------------------------------------
          function onCompanyChange(company) {
            viewModel.selectedCompany = company;
            var companyId = viewModel.selectedCompany.id;
            vehicleApiService.getVehiclesByCompany(companyId).$promise.then(onDataLoaded);
            companyApiService.getLocations(companyId).$promise.then(onLocationsLoaded);
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
            viewModel.modelNumber = null;
            viewModel.serialNumber = null;
            viewModel.folderCode = null;
            viewModel.estimatedAnnualVehicleHours = null;
            viewModel.telematic = false;
            viewModel.selectedEngineConfig = null;
            viewModel.selectedLocation = null;

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
                  model_number: viewModel.modelNumber,
                  serial_number: viewModel.serialNumber,
                  estimated_annual_vehicle_hours: viewModel.estimatedAnnualVehicleHours,
                  telematic: viewModel.telematic,
                  folder_code: viewModel.folderCode,
                  engine_config_id: viewModel.selectedEngineConfig.id,
                  location_id: viewModel.selectedLocation.id
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
            }

            vehicleApiService.save(data).then(function(data) {
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
          // remove
          //------------------------------------
          function remove() {
            if (viewModel.selectedData) {
              vehicleApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          initScope();

        }
      ]);
})();

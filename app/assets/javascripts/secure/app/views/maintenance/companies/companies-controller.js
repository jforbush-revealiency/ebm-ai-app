/**
 * The companies page
 *
 * Type: Controller
 *
 * ID: companiesController
 *
 */

(function () {
  'use strict';

  angular.module('companies').controller('companiesController',
      [
        '$scope',
        'messageBoxService',
        'companyApiService',
        function($scope, messageBoxService, companyApiService) {
          var viewModel = {
            allData: [],
            allLocations: [],
            id: null,
            code: null,
            description: null,
            averageDieselFuel: null,
            locationCode: null,
            locationDescription: null,
            locationAttainment: false,
            selectedLocationData: null,
            saveLocationClicked: false,
            search: '',
            showForm: false,
            showLocationForm: false,
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
            $scope.saveLocation = saveLocation;
            $scope.clearLocation = clearLocation;
            $scope.removeLocation = removeLocation;
            $scope.onDataSelected = onDataSelected;
            $scope.openLocationForm = openLocationForm;
            $scope.onLocationDataSelected = onLocationDataSelected;

            // Get Data
            companyApiService.getAll().$promise.then(onDataLoaded);
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData = data;
          }

          //------------------------------------
          // onLocationsLoaded
          //------------------------------------
          function onLocationsLoaded(data) {
            viewModel.allLocations = data;
          }

          //------------------------------------
          // onDataSelected
          //------------------------------------
          function onDataSelected(data) {
            if (data.selected) {
              companyApiService.getLocations(data.id).$promise.then(function(locations) {
                viewModel.allLocations = locations;
                viewModel.selectedData = data;
                viewModel.code = data.code;
                viewModel.description = data.description;
                viewModel.averageDieselFuel = data.average_diesel_fuel ? Number(data.average_diesel_fuel) : null;

                viewModel.showForm = true;
                viewModel.formTitle = 'Edit';
              });
            }
          }

          //------------------------------------
          // onLocationDataSelected
          //------------------------------------
          function onLocationDataSelected(data) {
            if (data.selected) {
              viewModel.selectedLocationData = data;
              viewModel.locationCode = data.code;
              viewModel.locationDescription = data.description;
              viewModel.locationAttainment = data.attainment;

              viewModel.showLocationForm = true;
              viewModel.formLocationTitle = 'Edit';
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
          // openLocationForm
          //------------------------------------
          function openLocationForm() {
            viewModel.showLocationForm = true;
            clearLocation(true);
          }

          //------------------------------------
          // clear
          //------------------------------------
          function clear(leaveFormOpen) {
            viewModel.code = null;
            viewModel.description = null;
            viewModel.averageDieselFuel = null;
            viewModel.locationCode = null;
            viewModel.locationDescription = null;
            viewModel.locationAttainment = false;
            viewModel.selectedLocationData = null;
            viewModel.allLocations.length = 0;

            if (viewModel.selectedData) {
              viewModel.selectedData.selected = false;
            }

            viewModel.selectedData = null;
            viewModel.showForm = !!leaveFormOpen;
            viewModel.formTitle = 'Add';

            $scope.form.$setPristine();
          }

          //------------------------------------
          // clearLocation
          //------------------------------------
          function clearLocation(leaveFormOpen) {
            viewModel.locationCode = null;
            viewModel.locationDescription = null;
            viewModel.locationAttainment = false;

            if (viewModel.selectedLocationData) {
              viewModel.selectedLocationData.selected = false;
            }

            viewModel.selectedLocationData = null;
            viewModel.showLocationForm = !!leaveFormOpen;
            viewModel.formLocationTitle = 'Add';

            $scope.form.$setPristine();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save() {
            if (viewModel.saveLocationClicked) {
              saveLocation();
              return;
            }

            console.log($scope.form);

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
                  average_diesel_fuel: viewModel.averageDieselFuel
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
            } else {
              data.data.attributes.location_attributes = {
                code: viewModel.locationCode,
                description: viewModel.locationDescription,
                attainment: !!viewModel.locationAttainment
              };
            }

            companyApiService.save(data).then(function(data) {
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
          // saveLocation
          //------------------------------------
          function saveLocation() {
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
                  code: viewModel.locationCode,
                  description: viewModel.locationDescription,
                  attainment: viewModel.locationAttainment,
                  company_id: viewModel.selectedData.id
                }
              }
            };
            if (viewModel.selectedLocationData) {
              data.data.id = viewModel.selectedLocationData.id; 
            }

            companyApiService.saveLocation(data).then(function(data) {
              if (viewModel.selectedLocationData) {
                var currentData = _.findWhere(viewModel.allLocations, {id: data.id});
                if (currentData) {
                  _.extend(currentData, data);
                }
              } else {
                viewModel.allLocations.push(data);
              }
              clearLocation();
            });
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove() {
            if (viewModel.selectedData) {
              companyApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          //------------------------------------
          // removeLocation
          //------------------------------------
          function removeLocation() {
            if (viewModel.allLocations.length === 1) {
              messageBoxService.show('md',
                                     'Errors were detected',
                                     'The last location cannot be deleted.',
                                     'OK');
              return;
            }

            if (viewModel.selectedLocationData) {
              companyApiService.removeLocation(viewModel.selectedLocationData).then(function(data) {
                viewModel.allLocations = _.reject(viewModel.allLocations, {id: data.id});
                clearLocation();
              });
            }
          }

          initScope();

        }
      ]);
})();

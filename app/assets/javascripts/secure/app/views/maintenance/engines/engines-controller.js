/**
 * The engines page
 *
 * Type: Controller
 *
 * ID: enginesController
 *
 */

(function () {
  'use strict';

  angular.module('engines').controller('enginesController',
      [
        '$scope',
        'messageBoxService',
        'engineApiService',
        'driveTypeApiService',
        'manufacturerApiService',
        function($scope, messageBoxService, engineApiService, driveTypeApiService, manufacturerApiService) {
          var viewModel = {
            allData: [],
            allManufacturers: [],
            allDriveTypes: [],
            id: null,
            code: null,
            description: null,
            isSingleStack: false,
            selectedManufacturer: null,
            selectedDriveType: null,
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

            // Get Data
            engineApiService.getAll().$promise.then(onDataLoaded);
            driveTypeApiService.getAll().$promise.then(onDriveTypesLoaded);
            manufacturerApiService.getAll().$promise.then(onManufacturersLoaded);
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData = data;
          }

          //------------------------------------
          // onManufacturersLoaded
          //------------------------------------
          function onManufacturersLoaded(data) {
            viewModel.allManufacturers = data;
          }

          //------------------------------------
          // onDriveTypesLoaded
          //------------------------------------
          function onDriveTypesLoaded(data) {
            viewModel.allDriveTypes = data;
          }

          //------------------------------------
          // onDataSelected
          //------------------------------------
          function onDataSelected(data) {
            if (data.selected) {
              viewModel.selectedData = data;
              viewModel.code = data.code;
              viewModel.description = data.description;
              viewModel.isSingleStack = data.is_single_stack;

              viewModel.selectedManufacturer = _.findWhere(viewModel.allManufacturers, 
                                                           {id: data.manufacturer_id});

              viewModel.selectedDriveType = _.findWhere(viewModel.allDriveTypes, 
                                                           {id: data.drive_type_id});

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
            viewModel.selectedManufacturer = null;
            viewModel.isSingleStack = false;

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
                  is_single_stack: viewModel.isSingleStack,
                  manufacturer_id: viewModel.selectedManufacturer.id,
                  drive_type_id: viewModel.selectedDriveType.id
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
            }

            engineApiService.save(data).then(function(data) {
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
              engineApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          initScope();

        }
      ]);
})();

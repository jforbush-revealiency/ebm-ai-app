/**
 * The parameters page
 *
 * Type: Controller
 *
 * ID: parametersController
 *
 */

(function () {
  'use strict';

  angular.module('parameters').controller('parametersController',
      [
        '$scope',
        'messageBoxService',
        'parameterApiService',
        function($scope, messageBoxService, parameterApiService) {
          var viewModel = {
            allData: [],
            id: null,
            code: null,
            value: null,
            parameterType: null,
            search: '',
            description: null,
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
            parameterApiService.getAll().$promise.then(onDataLoaded);
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData = data;
          }

          //------------------------------------
          // onDataSelected
          //------------------------------------
          function onDataSelected(data) {
            if (data.selected) {
              viewModel.selectedData = data;
              viewModel.code = data.code;
              viewModel.value = data.value;
              viewModel.description = data.description;
              viewModel.parameterType = data.parameter_type;

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
            viewModel.value = null;
            viewModel.description = null;
            viewModel.parameterType = null;

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
                  value: viewModel.value,
                  description: viewModel.description
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
            }

            parameterApiService.save(data).then(function(data) {
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
              parameterApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          initScope();

        }
      ]);
})();

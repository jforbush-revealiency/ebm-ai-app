/**
 * The users page
 *
 * Type: Controller
 *
 * ID: usersController
 *
 */

(function () {
  'use strict';

  angular.module('users').controller('usersController',
      [
        '$scope',
        'userApiService',
        'companyApiService',
        'messageBoxService',
        function($scope, userApiService, companyApiService, messageBoxService) {
          var viewModel = {
            allData: [],
            allRoles: [],
            allLocations: [],
            id: null,
            firstName: null,
            lastName: null,
            email: null,
            role: null,
            isActive: true,
            requirePasswordChange: false,
            selectedLocation: null,
            selectedRole: null,
            password: null,
            passwordConfirmation: null,
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
            userApiService.getAll().$promise.then(onDataLoaded);
            companyApiService.getAllLocations().$promise.then(onLocationsLoaded);
            setRoles();
          }

          //------------------------------------
          // setRoles
          //------------------------------------
          function setRoles() {
            viewModel.allRoles.push({code: 'site_admin', description: 'Site Admin'});
            viewModel.allRoles.push({code: 'data_entry', description: 'Data Entry'});
            //viewModel.allRoles.push({code: 'imports', description: 'Import Data'});
          }

          //------------------------------------
          // onDataLoaded
          //------------------------------------
          function onDataLoaded(data) {
            viewModel.allData = _.reject(data, function(item) {
              return item.role === 'imports';
            });
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
              viewModel.selectedData = data;
              viewModel.firstName = data.first_name;
              viewModel.lastName = data.last_name;
              viewModel.email = data.email;
              viewModel.isActive = data.is_active;
              viewModel.requirePasswordChange = data.require_password_change;
              viewModel.password = null;
              viewModel.passwordConfirmation = null;

              viewModel.selectedLocation = _.findWhere(viewModel.allLocations, 
                                                           {id: data.location_id});

              viewModel.selectedRole = _.findWhere(viewModel.allRoles, 
                                                           {code: data.role});
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
            viewModel.firstName = null;
            viewModel.lastName = null;
            viewModel.email = null;
            viewModel.isActive = true;
            viewModel.requirePasswordChange = false;
            viewModel.role = null;
            viewModel.password = null;
            viewModel.passwordConfirmation = null;
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

            var password1 = viewModel.password;
            var password2 = viewModel.passwordConfirmation;

            if (!password1) { password1 = ''; }
            if (!password2) { password2 = ''; }

            if (password1 !== password2) {
                messageBoxService.show('md',
                                   'Mismatched passwords',
                                   'The passwords do not match.',
                                   'OK');
              return;
            }

            var data = {
              data: {
                attributes: {
                  first_name: viewModel.firstName,
                  last_name: viewModel.lastName,
                  email: viewModel.email,
                  is_active: viewModel.isActive,
                  require_password_change: viewModel.requirePasswordChange,
                  location_id: viewModel.selectedLocation.id,
                  role: viewModel.selectedRole.code
                }
              }
            };

            if (viewModel.selectedData) {
              data.data.id = viewModel.selectedData.id; 
              if (viewModel.password && viewModel.password.length > 0) {
                data.data.attributes.password = viewModel.password;
              }
            } else {
              data.data.attributes.password = viewModel.password;
            }

            userApiService.save(data).then(function(data) {
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
              userApiService.remove(viewModel.selectedData).then(function(data) {
                viewModel.allData = _.reject(viewModel.allData, {id: data.id});
                clear();
              });
            }
          }

          initScope();

        }
      ]);
})();

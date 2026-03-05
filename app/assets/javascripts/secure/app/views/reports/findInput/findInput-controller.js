/** 
 * The find input page
 * 
 * Type: Controller
 * 
 * ID: findInputController
 * 
 */
(function () {
    'use strict';

    angular.module('findInput').controller('findInputController',
        [
        '$scope',
        '$location',
        'inputApiService',
        'messageBoxService',
        'companyApiService',
        'pageSettingsService',
        'currentUserApiService',
        function ($scope, $location, inputApiService, messageBoxService, 
                  companyApiService, pageSettingsService, currentUserApiService) {

          var PAGE_NAME = 'findInput';

          var viewModel = {
            allCompanies:[],
            allInputs: [],
            displayedData: [],
            selectedCompany: null,
            isSiteAdmin: false,
            search: '',
            limit: 10,
            offset: 0,
            pageNumber: 0
          };

          //----------------------------------------------
          // initScope
          //----------------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;

            // Functions
            $scope.search = search;
            $scope.onDelete = onDelete;
            $scope.customPipe = customPipe;
            $scope.onInputView = onInputView;
            $scope.onOutputView = onOutputView;
            $scope.onDataSelected = onDataSelected;
            $scope.onCompanyChange = onCompanyChange;
            $scope.onPageChange = onPageChange;

            // Get Data
            currentUserApiService.getCurrentUser().$promise.then(onCurrentUserLoaded);

            // Watches
            var watchHandle = $scope.$watch('viewModel.search', function(newVal, oldVal) {
              if (newVal !== oldVal) {
                search();
              }
            });

            var pageSettings = pageSettingsService.getPageSettings(PAGE_NAME);
            _.extend(viewModel, pageSettings);

            if (viewModel.search || viewModel.selectedCompany) {
              search();
            }
          }

          //----------------------------------------------
          // onCurrentUserLoaded
          //----------------------------------------------
          function onCurrentUserLoaded(data) {
            if (data.user.role === 'site_admin') {
              viewModel.isSiteAdmin = true;
              companyApiService.getAll().$promise.then(onCompaniesLoaded);
            }
          }

          //------------------------------------
          // onCompaniesLoaded
          //------------------------------------
          function onCompaniesLoaded(data) {
            viewModel.allCompanies.length = 0;
            viewModel.allCompanies.push({id: 0, code: "All Companies"});
            _.each(data, function(row) {
              viewModel.allCompanies.push(row);
            });
          }

          //------------------------------------
          // onCompanyChange
          //------------------------------------
          function onCompanyChange(company) {
            viewModel.selectedCompany = company;
            viewModel.allInputs.length = 0;
            viewModel.offset = 0;
            viewModel.pageNumber = 0;

            if (company.id === 0) {
              if (viewModel.search && $.trim(viewModel.search).length > 0) {
                search();
              } else {
                messageBoxService.show('md',
                                       'More search criteria',
                                       'Please enter more search criteria when searching across all companies.',
                                       'OK');
                return;
              }
            } else {
              search();
            }
          }

          //----------------------------------------------
          // onInputsLoaded
          //----------------------------------------------
          function onInputsLoaded(input) {
            viewModel.allInputs.length = 0;
            if (input) {
              viewModel.allInputs = input.data;
            }
          }

          //----------------------------------------------
          // onDataSelected
          //----------------------------------------------
          function onDataSelected(data) {
            //$location.path('/reports/view-input/' + data.id);
          }

          //----------------------------------------------
          // onInputView
          //----------------------------------------------
          function onInputView(data) {
            pageSettingsService.save(PAGE_NAME, viewModel);
            $location.path('/reports/view-input/' + data.id);
          }

          //----------------------------------------------
          // onOutputView
          //----------------------------------------------
          function onOutputView(data) {
            pageSettingsService.save(PAGE_NAME, viewModel);
            $location.path('/reports/view-results/' + data.output_id);
          }

          //----------------------------------------------
          // onDelete
          //----------------------------------------------
          function onDelete(data) {
            messageBoxService.show('md',
                                   'Confimation',
                                   'Are you sure you would like to delete this record?',
                                   'Yes', 'No').result.then(function(button) {
             if (button === 1) {
              inputApiService.remove(data).then(function(data) {
                viewModel.allInputs = _.reject(viewModel.allInputs, {id: data.id});
              });
             }
           });
          }

          //----------------------------------------------
          // search
          //----------------------------------------------
          function search() {
            var companyId = null;
            if (viewModel.selectedCompany && viewModel.selectedCompany.id > 0) {
              companyId = viewModel.selectedCompany.id;
            }
            inputApiService.getInputsBySearch(companyId, viewModel.search, viewModel.limit, 0).$promise.then(onInputsLoaded);
          }

          //------------------------------------
          // onPageChange
          //------------------------------------
          function onPageChange(pageNumber){
            viewModel.pageNumber = pageNumber;
          }

          //------------------------------------
          // customPipe
          //------------------------------------
          function customPipe(tableState){
            var companyId = null;
            if (viewModel.selectedCompany && viewModel.selectedCompany.id > 0) {
              companyId = viewModel.selectedCompany.id;
            }

            var limit = tableState.pagination.number;
            if (viewModel.pageNumber > 0) {
              tableState.pagination.start = limit * (viewModel.pageNumber-1);
            }
            var offset = tableState.pagination.start; 
            inputApiService.getInputsBySearch(companyId, viewModel.search, 
                                              limit, offset).$promise.then(function(data) {
              viewModel.allInputs = data.data;
              tableState.pagination.totalItemCount = data.total_records;
              tableState.pagination.numberOfPages = Math.ceil(data.total_records / viewModel.limit);
            });
          }

          initScope();
        }]);
})();

/** 
 * The export IO controller 
 * 
 * Type: Controller
 * 
 * ID: exportIOController
 * 
 */
(function () {
    'use strict';

    angular.module('exportIO').controller('exportIOController',
        [
        '$scope',
        '$window',
        '$location',
        'inputApiService',
        'messageBoxService',
        'companyApiService',
        'currentUserApiService',
        function ($scope, $window, $location, inputApiService, messageBoxService, 
                  companyApiService, currentUserApiService) {

          var viewModel = {
            allCompanies:[],
            selectedCompany: null,
            isSiteAdmin: false,
            startDate: moment().subtract(1, 'months').toDate(),
            endDate: moment().toDate(),
            dateFormat: 'dd-MMM-yyyy',
            startDatePicker: {
              opened: false
            },
            endDatePicker: {
              opened: false
            },
            endDateOpen: false,
            dateOptions: {
              formatYear:'yy',
              showWeeks: false
            },
            altInputFormats: ['M!/d!/yyyy']
          };

          //----------------------------------------------
          // initScope
          //----------------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;

            // Functions
            $scope.exportData = exportData;
            $scope.onStartDateClick = onStartDateClick;
            $scope.onEndDateClick = onEndDateClick;

            // Get Data
            currentUserApiService.getCurrentUser().$promise.then(onCurrentUserLoaded);
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
            viewModel.selectedCompany = viewModel.allCompanies[0];
          }

          //----------------------------------------------
          // onStartDateClick
          //----------------------------------------------
          function onStartDateClick() {
            viewModel.startDatePicker.opened = true;
          }

          //----------------------------------------------
          // onEndDateClick
          //----------------------------------------------
          function onEndDateClick() {
            viewModel.endDatePicker.opened = true;
          }

          //----------------------------------------------
          // exportData
          //----------------------------------------------
          function exportData() {
            if ($scope.form.$invalid) {
              messageBoxService.show('md',
                                     'Errors were detected',
                                     'Please correct the errors and try again.',
                                     'OK');
              return;
            }

            var startDate = moment(viewModel.startDate);
            var endDate = moment(viewModel.endDate);
            if (startDate.isAfter(endDate)) {
              messageBoxService.show('md',
                                     'Errors were detected',
                                     'The start date must be before the end date.',
                                     'OK');
              return;
            }

            var content = '/secure/api/inputs/export.csv?start_date=' + startDate.format('YYYY-MM-DD');
            content = content + '&end_date=' + endDate.format('YYYY-MM-DD');
            if (viewModel.selectedCompany && viewModel.selectedCompany.id > 0) {
              content = content + '&company_id=' + viewModel.selectedCompany.id;
            }
            var childWindow = $window.open(content);
          }

          initScope();
        }]);
})();

/** 
 * The export vehicle stats controller 
 * 
 * Type: Controller
 * 
 * ID: exportVehicleStatsController
 * 
 */
(function () {
    'use strict';

    angular.module('exportVehicleStats').controller('exportVehicleStatsController',
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
            startDate: moment().toDate(),
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

            var content = '/secure/api/vehicle_stats/export.csv?start_date=' + startDate.format('YYYY-MM-DD');
            content = content + '&end_date=' + endDate.format('YYYY-MM-DD');
            var childWindow = $window.open(content);
          }

          initScope();
        }]);
})();

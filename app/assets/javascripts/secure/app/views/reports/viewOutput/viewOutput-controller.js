/** 
 * The view output page
 * 
 * Type: Controller
 * 
 * ID: viewOutputController
 * 
 */
(function () {
    'use strict';

    angular.module('viewOutput').controller('viewOutputController',
        [
        '$scope',
        '$window',
        '$routeParams',
        'inputApiService',
        function ($scope, $window, $routeParams, inputApiService) {

          var viewModel = {
            submitted: null,
            output_id: $routeParams.id,
            output: {}
          };

          //----------------------------------------------
          // initScope
          //----------------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;

            // Functions
            $scope.back = back;
            $scope.rowColor = rowColor;

            // Get Data
            inputApiService.getOutput(viewModel.output_id).$promise.then(onOutputLoaded);
          }

          //----------------------------------------------
          // onOutputLoaded
          //----------------------------------------------
          function onOutputLoaded(output) {
            viewModel.output = output;
          }

          //----------------------------------------------
          // back
          //----------------------------------------------
          function back() {
            $window.history.back();
          }

          //----------------------------------------------
          // rowColor
          //----------------------------------------------
          function rowColor(code, value) {
            if (code === value) {
              return 'row-ok';
            } else if (code && code.includes('_extremely_')) {
              return 'row-extremely';
            } else {
              return null;
            }
          }

          initScope();
        }]);
})();

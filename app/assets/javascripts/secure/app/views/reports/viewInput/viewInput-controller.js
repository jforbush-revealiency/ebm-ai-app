/** 
 * The view input page
 * 
 * Type: Controller
 * 
 * ID: viewInputController
 * 
 */
(function () {
    'use strict';

    angular.module('viewInput').controller('viewInputController',
        [
        '$scope',
        '$window',
        '$routeParams',
        'inputApiService',
        function ($scope, $window, $routeParams, inputApiService) {

          var viewModel = {
            submitted: null,
            input_id: $routeParams.id,
            input: {}
          };

          //----------------------------------------------
          // initScope
          //----------------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;

            // Functions
            $scope.back = back;

            // Get Data
            inputApiService.getInput(viewModel.input_id).$promise.then(onInputLoaded);
          }

          //----------------------------------------------
          // onInputLoaded
          //----------------------------------------------
          function onInputLoaded(input) {
            viewModel.input = input;
          }

          //----------------------------------------------
          // back
          //----------------------------------------------
          function back() {
            $window.history.back();
          }



          initScope();
        }]);
})();

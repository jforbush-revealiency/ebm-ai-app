/**
 * The home page 
 *
 * Type: Controller
 *
 * ID: homeController
 *
 */

(function () {
  'use strict';

  angular.module('home').controller('homeController',
      [
        '$scope',
        function($scope) {

          var viewModel = {
          };

          //------------------------------------
          // initScope
          //------------------------------------
          function initScope() {
            // Properties
            $scope.viewModel = viewModel;
            
            // Functions

            // Get Data
          }

          initScope();

        }
      ]);
})();

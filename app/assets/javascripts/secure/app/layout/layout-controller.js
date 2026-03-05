/**
 * Controller for the application 
 *
 * Type: Controller
 *
 * ID: app
 *
 */
(function () {
  'use strict';

  angular.module('app').controller('layoutController', [
    '$scope',
    '$location',
    'currentUserApiService',
    function($scope, $location, currentUserApiService) {
      var viewModel = {
        name: null,
        userProfile: null
      };

      //------------------------------------
      // initScope
      //------------------------------------
      function initScope() {
        // Properties
        $scope.viewModel = viewModel;
        
        // Functions

        // Get Data
        currentUserApiService.getCurrentUser().$promise.then(onCurrentUserLoaded);
      }

      //------------------------------------
      // onCurrentUserLoaded
      //------------------------------------
      function onCurrentUserLoaded(currentUser) {
        viewModel.userProfile = currentUser.user;
        viewModel.name = currentUser.user.first_name + ' ' + currentUser.user.last_name;
        if (viewModel.userProfile.require_password_change) {
          $location.path('/change-password/required');
        }
      }

      initScope();
    }
  ]);
})();

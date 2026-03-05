/** 
 * The changePassword page
 * 
 * Type: Controller
 * 
 * ID: changePasswordController
 * 
 */
(function () {
    'use strict';

    angular.module('changePassword').controller('changePasswordController',
        [
        '$q',
        '$scope',
        '$window',
        '$routeParams',
        'messageBoxService',
        'currentUserApiService',
        function ($q, $scope, $window, $routeParams, messageBoxService, currentUserApiService) {

            var viewModel = {
              title: null,
              newPassword: null,
              newPasswordConfirmation: null,
              requirePasswordChange: $routeParams.required === 'required'
            };

            //----------------------------------------------
            // initScope
            //----------------------------------------------
            function initScope() {
              // Properties
              $scope.viewModel = viewModel;

              // Functions
              $scope.cancel = cancel;
              $scope.changePassword = changePassword;

              // Get Data

              if (viewModel.requirePasswordChange) {
                viewModel.title = 'You are required to change your password now.';
              } else {
                viewModel.title = 'Change Password';
              }
            }

            //----------------------------------------------
            // changePassword
            //----------------------------------------------
            function changePassword() {
                if ($scope.form.$invalid) {
                    messageBoxService.show('md',
                                       'Errors were detected',
                                       'Please correct the errors and try again.',
                                       'OK');
                    return;
                }

                var password1 = viewModel.newPassword;
                var password2 = viewModel.newPasswordConfirmation;

                if (!password1) { password1 = ''; }
                if (!password2) { password2 = ''; }

                if (password1 !== password2) {
                    messageBoxService.show('md',
                                       'Mismatched passwords',
                                       'The passwords do not match.',
                                       'OK');
                  return;
                }

                currentUserApiService.changePassword(viewModel.newPassword).$promise.then(function(data) {
                    messageBoxService.show('md',
                                       'Successfully changed',
                                       'Your password has been successfully changed. Please login with your new password.',
                                       'OK').result.then(function(button) {
                                         $window.location.href = '/secure/users/logout';
                                       });
                });
            }
            
            //----------------------------------------------
            // cancel
            //----------------------------------------------
            function cancel() {
                $uibModalInstance.close();
            }
           
            initScope();
        }]);
})();

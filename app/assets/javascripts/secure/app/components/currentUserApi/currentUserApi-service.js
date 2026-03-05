/**
 * A service for interfacing with the current user 
 *
 * Type: Service
 *
 * ID: currentUserApiService
 *
 */

(function () {
  'use strict';

  angular.module('currentUserApi').factory('currentUserApiService',
      [
        '$resource',
        function($resource) {
          var CurrentUser = $resource('/secure/api/current_user',null, {
            'update': { method: 'PUT', url: '/secure/api/users/current_change_password'}
          });

          //------------------------------------
          // getCurrentUser 
          //------------------------------------
          function getCurrentUser() {
            return CurrentUser.get();
          }

          //------------------------------------
          // changePassword 
          //------------------------------------
          function changePassword(password) {
            return CurrentUser.update({password: password});
          }

          return {
            getCurrentUser: getCurrentUser,
            changePassword: changePassword
          };
        }
      ]);
})();



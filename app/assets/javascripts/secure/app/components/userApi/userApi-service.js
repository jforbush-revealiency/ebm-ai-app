/**
 * A service for interfacing with the users
 *
 * Type: Service
 *
 * ID: userApiService
 *
 */

(function () {
  'use strict';

  angular.module('userApi').factory('userApiService',
      [
        '$resource',
        function($resource) {
          var User = $resource('/secure/api/users/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return User.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new User(data);
            if (data.data.id) {
              return obj.$update({id: data.data.id});
            } else {
              return obj.$save();
            }
          }

          //------------------------------------
          // remove
          //------------------------------------
          function remove(data) {
            var obj = new User(data);
            return obj.$delete();
          }

          return {
            getAll: getAll,
            save: save,
            remove: remove
          };
        }
      ]);
})();



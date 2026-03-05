/**
 * A service for interfacing with the engines
 *
 * Type: Service
 *
 * ID: engineApiService
 *
 */

(function () {
  'use strict';

  angular.module('engineApi').factory('engineApiService',
      [
        '$resource',
        function($resource) {
          var Engine = $resource('/secure/api/engines/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Engine.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Engine(data);
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
            var obj = new Engine(data);
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



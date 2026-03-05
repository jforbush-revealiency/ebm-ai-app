/**
 * A service for interfacing with the parameters
 *
 * Type: Service
 *
 * ID: parameterApiService
 *
 */

(function () {
  'use strict';

  angular.module('parameterApi').factory('parameterApiService',
      [
        '$resource',
        function($resource) {
          var Parameter = $resource('/secure/api/parameters/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return Parameter.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new Parameter(data);
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
            var obj = new Parameter(data);
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



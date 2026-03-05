/**
 * A service for interfacing with the engine configurations
 *
 * Type: Service
 *
 * ID: engineConfigApiService
 *
 */

(function () {
  'use strict';

  angular.module('engineConfigApi').factory('engineConfigApiService',
      [
        '$resource',
        function($resource) {
          var EngineConfig = $resource('/secure/api/engine_configs/:id', {id: '@id'},{
            'update': { method: 'PUT'}
          });

          //------------------------------------
          // getAll 
          //------------------------------------
          function getAll() {
            return EngineConfig.query();
          }

          //------------------------------------
          // save
          //------------------------------------
          function save(data) {
            var obj = new EngineConfig(data);
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
            var obj = new EngineConfig(data);
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


